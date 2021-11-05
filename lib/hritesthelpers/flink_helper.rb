module HRITestHelpers
  class FlinkHelper

    def initialize(flink_url)
      @request_helper = RequestHelper.new
      @base_url = flink_url
    end

    def get_overview(override_headers = {})
      url = "#{@base_url}/overview"
      headers = { 'Accept' => 'application/json',
                  'Content-Type' => 'application/json' }.merge(override_headers)
      @request_helper.rest_get(url, headers)
    end

    def upload_jar(jar_file, override_headers = {})
      url = "#{@base_url}/jars/upload"
      headers = { 'Accept' => 'application/json',
                  'Content-Type' => 'application/x-java-archive' }.merge(override_headers)
      @request_helper.rest_post(url, { jarfile: jar_file }, headers)
    end

    def get_jars(override_headers = {})
      url = "#{@base_url}/jars"
      headers = { 'Accept' => 'application/json',
                  'Content-Type' => 'application/json' }.merge(override_headers)
      @request_helper.rest_get(url, headers)
    end

    def delete_jar(jar_id, override_headers = {})
      url = "#{@base_url}/jars/#{jar_id}"
      headers = { 'Accept' => 'application/json',
                  'Content-Type' => 'application/json' }.merge(override_headers)
      @request_helper.rest_delete(url, nil, headers)
    end

    def run_job(jar_id, job_info, parallelism = nil, override_headers = {})
      url = "#{@base_url}/jars/#{jar_id}/run"
      url += "?parallelism=#{parallelism}" if parallelism
      headers = { 'Accept' => 'application/json',
                  'Content-Type' => 'application/json' }.merge(override_headers)
      @request_helper.rest_post(url, job_info, headers)
    end

    def get_jobs(override_headers = {})
      url = "#{@base_url}/jobs"
      headers = { 'Accept' => 'application/json',
                  'Content-Type' => 'application/json' }.merge(override_headers)
      @request_helper.rest_get(url, headers)
    end

    def get_job(job_id, override_headers = {})
      url = "#{@base_url}/jobs/#{job_id}"
      headers = { 'Accept' => 'application/json',
                  'Content-Type' => 'application/json' }.merge(override_headers)
      @request_helper.rest_get(url, headers)
    end

    def get_job_exceptions(job_id, override_headers = {})
      url = "#{@base_url}/jobs/#{job_id}/exceptions"
      headers = { 'Accept' => 'application/json',
                  'Content-Type' => 'application/json' }.merge(override_headers)
      @request_helper.rest_get(url, headers)
    end

    def get_job_checkpoints(job_id, override_headers = {})
      url = "#{@base_url}/jobs/#{job_id}/checkpoints"
      headers = { 'Accept' => 'application/json',
                  'Content-Type' => 'application/json' }.merge(override_headers)
      @request_helper.rest_get(url, headers)
    end

    def stop_job(job_id, override_headers = {})
      url = "#{@base_url}/jobs/#{job_id}/stop"
      headers = { 'Accept' => 'application/json',
                  'Content-Type' => 'application/json' }.merge(override_headers)
      @request_helper.rest_post(url, { targetDirectory: "savepoints/", drain: false }.to_json, headers)
    end

    def delete_old_jars(jar_name, token)
      response = get_jars({ 'Authorization' => "Bearer #{token}" })
      raise 'Failed to get Flink jars' unless response.code == 200
      parsed_response = JSON.parse(response.body)
      unless parsed_response['files'].empty?
        parsed_response['files'].each do |file|
          if file['name'] == jar_name
            response = delete_jar(file['id'], { 'Authorization' => "Bearer #{token}" })
            raise "Failed to delete Flink jar with ID: #{file['id']}" unless response.code == 200
          end
        end
      end
    end

    def verify_jar_upload(jar_name, token)
      jar_found = false
      response = get_jars({ 'Authorization' => "Bearer #{token}" })
      raise 'Failed to get Flink jars' unless response.code == 200
      parsed_response = JSON.parse(response.body)
      parsed_response['files'].each do |file|
        if file['name'] == jar_name
          @test_jar_id = file['id']
          jar_found = true
        end
      end
      raise "Jar with name '#{jar_name}' not found" unless jar_found
      Logger.new(STDOUT).info("New Jar Created With ID: #{@test_jar_id}")
      @test_jar_id
    end

    def verify_jar_deleted(jar_id, token)
      jar_found = false
      response = get_jars({ 'Authorization' => "Bearer #{token}" })
      raise 'Failed to get Flink jars' unless response.code == 200
      parsed_response = JSON.parse(response.body)
      parsed_response['files'].each do |file|
        jar_found = true if file['id'] == jar_id
      end
      raise "Failed to delete Flink jar with ID: #{jar_id}" if jar_found
      Logger.new(STDOUT).info("Test Jar ID #{jar_id} successfully deleted")
    end

    def start_flink_job(jar_id, kafka_brokers, sasl_plain_password, input_topic, hri_service_url, client_id, client_secret, oauth_url, audience, batch_complete_delay, token, parallelism = nil)
      response = run_job(jar_id,
                         {
                           programArgsList: [
                             '--brokers',
                             kafka_brokers,
                             '--password',
                             sasl_plain_password,
                             '--input',
                             input_topic,
                             '--mgmt-url',
                             hri_service_url,
                             '--client-id',
                             client_id,
                             '--client-secret',
                             client_secret,
                             '--oauth-url',
                             oauth_url,
                             '--audience',
                             audience,
                             "--batch-completion-delay",
                             batch_complete_delay]
                         }.to_json,
                         parallelism,
                         { 'Authorization' => "Bearer #{token}" })
      raise "Failed to run Flink job from jar with ID: #{jar_id}" unless response.code == 200
      JSON.parse(response.body)['jobid']
    end

    def verify_job_state(job_id, token, state)
      Timeout.timeout(30, nil, "The state of Flink job with ID: #{job_id} is not '#{state}'") do
        while true
          response = get_job(job_id, { 'Authorization' => "Bearer #{token}" })
          raise "Failed to get Flink job with ID: #{job_id}" unless response.code == 200
          response_body = JSON.parse(response.body)
          break if response_body['state'] == state && response_body['vertices'].map { |v| v['status']}.select { |status| status != state}.empty?
        end
      end
      state == 'RUNNING' ? Logger.new(STDOUT).info("New Job Running With ID: #{job_id}") : Logger.new(STDOUT).info("Test Job ID #{@test_job_id} successfully canceled")
    end

    def upload_jar_from_dir(jar_name, from_dir, flink_oauth_token, jar_name_regex)
      # Delete any jars leftover from prior testing
      delete_old_jars(jar_name, flink_oauth_token)

      # Get jar name from dependencies folder
      original_jar_name = Dir.entries(from_dir).select { |n| n.match(jar_name_regex) }[0]
      original_absolute_path = File.absolute_path("#{from_dir}/#{original_jar_name}")
      Logger.new(STDOUT).info("Found validation jar: " + original_absolute_path)

      # Rename jar before uploading it to flink repo
      renamed_absolute_path = File.absolute_path("#{from_dir}/#{jar_name}")
      File.rename(File.absolute_path("#{from_dir}/#{original_jar_name}"), renamed_absolute_path)

      # Upload jar
      response = upload_jar(File.open(renamed_absolute_path), { 'Authorization' => "Bearer #{flink_oauth_token}" })

      # Reset jar name
      File.rename(renamed_absolute_path, original_absolute_path)

      # Check return code and return jar id from response
      raise('Failed to push validation jar') unless response.code == 200
      verify_jar_upload(jar_name, flink_oauth_token)
    end

  end
end