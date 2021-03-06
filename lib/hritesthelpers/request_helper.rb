module HRITestHelpers
  class RequestHelper

    def rest_get(url, headers, overrides = {})
      @hri_api_info = { method: :get, url: url, headers: headers }.merge(overrides)
      response_rescue_wrapper do
        rest_client_resource_for
      end
    end

    def rest_post(url, body, override_headers = {}, overrides = {})
      headers = { 'Accept' => '*/*' }.merge(override_headers)
      @hri_api_info = { method: :post, url: url, headers: headers, payload: body }.merge(overrides)
      response_rescue_wrapper do
        rest_client_resource_for
      end
    end

    def rest_put(url, body, override_headers = {}, overrides = {})
      headers = { 'Accept' => '*/*' }.merge(override_headers)
      @hri_api_info = { method: :put, url: url, headers: headers, payload: body }.merge(overrides)
      response_rescue_wrapper do
        rest_client_resource_for
      end
    end

    def rest_delete(url, body, override_headers = {}, overrides = {})
      headers = { 'Accept' => '*/*' }.merge(override_headers)
      @hri_api_info = { method: :delete, url: url, headers: headers, payload: body }.merge(overrides)
      response_rescue_wrapper do
        rest_client_resource_for
      end
    end

    def exec_command(cmd)
      stdin, stdout, stderr, status = Open3.popen3(cmd)
      { stdout: stdout.read, stderr: stderr.read, status: status.value.success? }
    end

    private

    def rest_client_resource_for
      @hri_api_info[:verify_ssl] = OpenSSL::SSL::VERIFY_NONE

      response_rescue_wrapper do
        RestClient::Request.execute(@hri_api_info)
      end
    end

    def logger_message(info, error)
      printed_info = if info[:headers].nil?
                       info
                     else
                       headers = info[:headers].dup
                       headers['Authorization'] = headers['Authorization'].split(' ')[0] + ' [REDACTED]' if headers['Authorization']
                       info.merge(headers: headers)
                     end
      Logger.new(STDOUT).info("Received exception hitting endpoint: #{printed_info}. Exception: #{error}, response: #{error.response}")
    end

    def response_rescue_wrapper
      yield
    rescue Exception => e
      raise e unless defined?(e.response)
      logger_message(@hri_api_info, e)
      e.response
    end

  end
end