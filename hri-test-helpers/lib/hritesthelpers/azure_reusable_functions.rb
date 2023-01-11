module HRITestHelpers
  class AzureReusableFunctions

    def initialize
      @request_helper = RequestHelper.new
    end

    # def mongo(_mongodb_credentials = {})
    #   @headers = { 'Content-Type': 'application/json' }
    #   client = Mongo::Client.new('mongodb://hi-dp-tst-eastus-cosmos-mongo-api-hri:Jl6rN2wUFpROlr4Cxse61ET51TB1qwZTZXfD1IwotXQKUBUaEGjBXr8DqKAKonhBkhwSxdLIkJitZUE9X2liSg==@hi-dp-tst-eastus-cosmos-mongo-api-hri.mongo.cosmos.azure.com:10255/?ssl=true&replicaSet=globaldb&retrywrites=false&maxIdleTimeMS=120000&appName=@hi-dp-tst-eastus-cosmos-mongo-api-hri@' , :database => 'HRI-DEV')
    #   db = client.database
    #   collection = client[:'HRI-Mgmt']
    #   # puts collection.find( { tenantid: 'q-batches' } ).first
    # end

    def get_client_id_and_secret()
      return ['c33ac4da-21c6-426b-abcc-27e24ff1ccf9','GxF8Q~XfZyLRQBZ4mjwgEogVWwGjtzJh7ZPzgagw']
    end

    def fetch_access_token()
      credentials = get_client_id_and_secret()
      response = @request_helper.rest_post("https://login.microsoftonline.com/ceaa63aa-5d5c-4c7d-94b0-02f9a3ab6a8c/oauth2/v2.0/token",{'grant_type' => 'client_credentials','scope' => 'c33ac4da-21c6-426b-abcc-27e24ff1ccf9/.default', 'client_secret' => 'GxF8Q~XfZyLRQBZ4mjwgEogVWwGjtzJh7ZPzgagw', 'client_id' => 'c33ac4da-21c6-426b-abcc-27e24ff1ccf9'}, {'Content-Type' => 'application/x-www-form-urlencoded', 'Accept' => 'application/json', 'Authorization' => "Basic #{Base64.encode64("#{credentials[0]}:#{credentials[1]}").delete("\n")}" })
      raise 'App ID token request failed' unless response.code == 200
      JSON.parse(response.body)['access_token']
    end

    # def es_get_batch(index, batch_id)
    #   rest_get("#{@hri_base_url}/#{index}-batches/_doc/#{batch_id}", @headers, @basic_auth)
    # end
    #
    # def es_batch_update(index, batch_id, script)
    #   # wait_for waits for an index refresh to happen, so increase the standard timeout
    #   rest_post("#{@hri_base_url}/#{index}-batches/_doc/#{batch_id}/_update?refresh=wait_for", script, @headers, @basic_auth)
    # end
    #
    # def hri_post_tenant(tenant_id, request_body = nil, override_headers = {})
    #   url = "#{@hri_base_url}/tenants/#{tenant_id}"
    #   @az_token = get_access_token()
    #   headers = { 'Accept' => 'application/json',
    #               'Content-Type' => 'application/json',
    #               'Authorization' => "Bearer #{@az_token}" }.merge(override_headers)
    #   rest_post(url, request_body, headers)
    # end
    #
    # def hri_post_tenant_stream(tenant_id, integrator_id, request_body, override_headers = {}, delete_auth = false)
    #   url = "#{@hri_base_url}/tenants/#{tenant_id}/streams/#{integrator_id}"
    #   @az_token = get_access_token()
    #   headers = { 'Accept' => 'application/json',
    #               'Content-Type' => 'application/json',
    #               'Authorization' => "Bearer #{@az_token}" }.merge(override_headers)
    #   headers.delete('Authorization') if delete_auth
    #   rest_post(url, request_body, headers, {})
    # end

    # def hri_delete_tenant(tenant_id, override_headers = {})
    #   url = "#{@hri_base_url}/tenants/#{tenant_id}"
    #   @az_token = get_access_token()
    #   headers = { 'Accept' => 'application/json',
    #               'Content-Type' => 'application/json',
    #               'Authorization' => "Bearer #{@az_token}" }.merge(override_headers)
    #   rest_delete(url, nil, headers, {})
    # end
    #
    # def hri_get_tenant_streams(tenant_id, override_headers = {}, delete_auth = false)
    #   url = "#{@hri_base_url}/tenants/#{tenant_id}/streams"
    #   @az_token = get_access_token()
    #   headers = { 'Accept' => 'application/json',
    #               'Content-Type' => 'application/json',
    #               'Authorization' => "Bearer #{@az_token}" }.merge(override_headers)
    #   headers.delete('Authorization') if delete_auth
    #   rest_get(url, headers)
    # end
    #
    #
    # def hri_get_tenant(tenant_id, override_headers = {})
    #   url = "#{@hri_base_url}/tenants/#{tenant_id}"
    #   @az_token = get_access_token()
    #   headers = { 'Accept' => 'application/json',
    #               'Content-Type' => 'application/json',
    #               'Authorization' => "Bearer #{@az_token}" }.merge(override_headers)
    #   rest_get(url, headers)
    # end
    #
    # def hri_get_tenants(override_headers = {})
    #   url = "#{@hri_base_url}/tenants"
    #   @az_token = get_access_token()
    #   headers = { 'Accept' => 'application/json',
    #               'Content-Type' => 'application/json',
    #               'Authorization' => "Bearer #{@az_token}" }.merge(override_headers)
    #   rest_get(url, headers)
    # end
    #
    # def hri_delete_tenant_stream(tenant_id, integrator_id, override_headers = {}, delete_auth = false)
    #   url = "#{@hri_base_url}/tenants/#{tenant_id}/streams/#{integrator_id}"
    #   @az_token = get_access_token()
    #   headers = { 'Accept' => 'application/json',
    #               'Content-Type' => 'application/json',
    #               'Authorization' => "Bearer #{@az_token}" }.merge(override_headers)
    #   headers.delete('Authorization') if delete_auth
    #   rest_delete(url, nil, headers, {})
    # end
    #
    # def hri_get_batch(tenant_id, batch_id, override_headers = {})
    #   url = "#{@hri_base_url}/tenants/#{tenant_id}/batches/#{batch_id}"
    #   @az_token = get_access_token()
    #   headers = { 'Accept' => 'application/json',
    #               'Content-Type' => 'application/json',
    #               'Authorization' => "Bearer #{@az_token}" }.merge(override_headers)
    #   rest_get(url, headers)
    # end
    #
    # def hri_get_batches(tenant_id, query_params = nil, override_headers = {})
    #   url = "#{@hri_base_url}/tenants/#{tenant_id}/batches"
    #   url += "?#{query_params}" unless query_params.nil?
    #   @az_token = get_access_token()
    #   headers = { 'Accept' => 'application/json',
    #               'Content-Type' => 'application/json',
    #               'Authorization' => "Bearer #{@az_token}" }.merge(override_headers)
    #   rest_get(url, headers)
    # end
    #
    # def hri_put_batch(tenant_id, batch_id, action, additional_params = {}, override_headers = {})
    #   url = "#{@hri_base_url}/tenants/#{tenant_id}/batches/#{batch_id}/action/#{action}"
    #   @az_token = get_access_token()
    #   headers = { 'Accept' => 'application/json',
    #               'Content-Type' => 'application/json',
    #               'Authorization' => "Bearer #{@az_token}"}.merge(override_headers)
    #   @request_helper.rest_put(url, additional_params.to_json, headers)
    # end
    #
    # def hri_post_batch(tenant_id, request_body, override_headers = {})
    #   url = "#{@hri_base_url}/tenants/#{tenant_id}/batches"
    #   @az_token = get_access_token()
    #   headers = { 'Accept' => 'application/json',
    #               'Content-Type' => 'application/json',
    #               'Authorization' => "Bearer #{@az_token}"}.merge(override_headers)
    #   rest_post(url, request_body, headers)
    # end
    #
    # def response_rescue_wrapper
    #   yield
    # rescue Exception => e
    #   raise e unless defined?(e.response)
    #   logger_message(@hri_api_info, e)
    #   e.response
    # end
    #
    # def rest_client_resource_for
    #   @hri_api_info[:verify_ssl] = OpenSSL::SSL::VERIFY_NONE
    #
    #   response_rescue_wrapper do
    #     RestClient::Request.execute(@hri_api_info)
    #   end
    # end
    #
    # def rest_get(url, headers, overrides = {})
    #   @hri_api_info = { method: :get, url: url, headers: headers }.merge(overrides)
    #   response_rescue_wrapper do
    #     rest_client_resource_for
    #   end
    # end
    #
    # def rest_post(url, body, override_headers = {}, overrides = {})
    #   headers = { 'Accept' => '*/*' }.merge(override_headers)
    #   @hri_api_info = { method: :post, url: url, headers: headers, payload: body }.merge(overrides)
    #   response_rescue_wrapper do
    #     rest_client_resource_for
    #   end
    # end
    #
    # def rest_put(url, body, override_headers = {}, overrides = {})
    #   headers = { 'Accept' => '*/*' }.merge(override_headers)
    #   @hri_api_info = { method: :put, url: url, headers: headers, payload: body }.merge(overrides)
    #   response_rescue_wrapper do
    #     rest_client_resource_for
    #   end
    # end
    #
    # def rest_delete(url, body, override_headers = {}, overrides = {})
    #   headers = { 'Accept' => '*/*' }.merge(override_headers)
    #   @hri_api_info = { method: :delete, url: url, headers: headers, payload: body }.merge(overrides)
    #   response_rescue_wrapper do
    #     rest_client_resource_for
    #   end
    # end
    #
    # def logger_message(info, error)
    #   printed_info = if info[:headers].nil?
    #                    info
    #                  else
    #                    headers = info[:headers].dup
    #                    headers['Authorization'] = headers['Authorization'].split(' ')[0] + ' [REDACTED]' if headers['Authorization']
    #                    info.merge(headers: headers)
    #                  end
    #   Logger.new(STDOUT).info("Received exception hitting endpoint: #{printed_info}. Exception: #{error}, response: #{error.response}")
    # end
    #
    # def hri_custom_request(request_url, request_body = nil, override_headers = {}, request_type)
    #   url = "#{@hri_base_url}#{request_url}"
    #   @az_token = get_access_token()
    #   headers = { 'Accept' => 'application/json',
    #               'Content-Type' => 'application/json' }.merge(override_headers)
    #   case request_type
    #   when 'GET'
    #     rest_get(url, headers)
    #   when 'PUT'
    #     rest_put(url, request_body, headers)
    #   when 'POST'
    #     headers['Authorization'] = "Bearer #{@az_token}"
    #     rest_post(url, request_body, headers)
    #   when 'DELETE'
    #     headers['Authorization'] = "Bearer #{@az_token}"
    #     rest_delete(url, nil, headers)
    #   else
    #     raise "Invalid request type: #{request_type}"
    #   end
    # end
    #
    #
    # def get_topics
    #   response = rest_get("#{@admin_url}/admin/topics", @headers)
    #   puts "================ Topics Created are =======================> "
    #   puts response
    #   raise 'Failed to get Event Streams topics' unless response.code == 200
    #   puts JSON.parse(response.body).map { |topic| topic['name']}
    # end





  end

end
