module HRITestHelpers
  class MgmtAPIHelper

    def initialize(hri_url, iam_token)
      @request_helper = RequestHelper.new
      @base_url = hri_url
      @iam_token = iam_token
    end

    def hri_get_batches(tenant_id, query_params = nil, override_headers = {})
      url = "#{@base_url}/tenants/#{tenant_id}/batches"
      url += "?#{query_params}" unless query_params.nil?
      headers = { 'Accept' => 'application/json',
                  'Content-Type' => 'application/json' }.merge(override_headers)
      @request_helper.rest_get(url, headers)
    end

    def hri_get_batch(tenant_id, batch_id, override_headers = {})
      url = "#{@base_url}/tenants/#{tenant_id}/batches/#{batch_id}"
      headers = { 'Accept' => 'application/json',
                  'Content-Type' => 'application/json' }.merge(override_headers)
      @request_helper.rest_get(url, headers)
    end

    def hri_post_batch(tenant_id, request_body, override_headers = {})
      url = "#{@base_url}/tenants/#{tenant_id}/batches"
      headers = { 'Accept' => 'application/json',
                  'Content-Type' => 'application/json' }.merge(override_headers)
      @request_helper.rest_post(url, request_body, headers)
    end

    def hri_put_batch(tenant_id, batch_id, action, additional_params = {}, override_headers = {})
      url = "#{@base_url}/tenants/#{tenant_id}/batches/#{batch_id}/action/#{action}"
      headers = { 'Accept' => 'application/json',
                  'Content-Type' => 'application/json' }.merge(override_headers)
      @request_helper.rest_put(url, additional_params.to_json, headers)
    end

    def hri_post_tenant(tenant_id, request_body = nil, override_headers = {})
      url = "#{@base_url}/tenants/#{tenant_id}"
      headers = { 'Accept' => 'application/json',
                  'Content-Type' => 'application/json',
                  'Authorization' => "Bearer #{@iam_token}" }.merge(override_headers)
      @request_helper.rest_post(url, request_body, headers)
    end

    def hri_get_tenants(override_headers = {})
      url = "#{@base_url}/tenants"
      headers = { 'Accept' => 'application/json',
                  'Content-Type' => 'application/json',
                  'Authorization' => "Bearer #{@iam_token}" }.merge(override_headers)
      @request_helper.rest_get(url, headers)
    end

    def hri_get_tenant(tenant_id, override_headers = {})
      url = "#{@base_url}/tenants/#{tenant_id}"
      headers = { 'Accept' => 'application/json',
                  'Content-Type' => 'application/json',
                  'Authorization' => "Bearer #{@iam_token}" }.merge(override_headers)
      @request_helper.rest_get(url, headers)
    end

    def hri_delete_tenant(tenant_id, override_headers = {})
      url = "#{@base_url}/tenants/#{tenant_id}"
      headers = { 'Accept' => 'application/json',
                  'Content-Type' => 'application/json',
                  'Authorization' => "Bearer #{@iam_token}" }.merge(override_headers)
      @request_helper.rest_delete(url, nil, headers, {})
    end

    def hri_get_tenant_streams(tenant_id, override_headers = {})
      url = "#{@base_url}/tenants/#{tenant_id}/streams"
      headers = { 'Accept' => 'application/json',
                  'Content-Type' => 'application/json',
                  'Authorization' => "Bearer #{@iam_token}" }.merge(override_headers)
      @request_helper.rest_get(url, headers)
    end

    def hri_post_tenant_stream(tenant_id, integrator_id, request_body, override_headers = {})
      url = "#{@base_url}/tenants/#{tenant_id}/streams/#{integrator_id}"
      headers = { 'Accept' => 'application/json',
                  'Content-Type' => 'application/json',
                  'Authorization' => "Bearer #{@iam_token}" }.merge(override_headers)
      @request_helper.rest_post(url, request_body, headers, {})
    end

    def hri_delete_tenant_stream(tenant_id, integrator_id, override_headers = {})
      url = "#{@base_url}/tenants/#{tenant_id}/streams/#{integrator_id}"
      headers = { 'Accept' => 'application/json',
                  'Content-Type' => 'application/json',
                  'Authorization' => "Bearer #{@iam_token}" }.merge(override_headers)
      @request_helper.rest_delete(url, nil, headers, {})
    end

    def hri_custom_request(request_url, request_body = nil, override_headers = {}, request_type)
      url = "#{@base_url}#{request_url}"
      headers = { 'Accept' => 'application/json',
                  'Content-Type' => 'application/json' }.merge(override_headers)
      case request_type
        when 'GET'
          @request_helper.rest_get(url, headers)
        when 'PUT'
          @request_helper.rest_put(url, request_body, headers)
        when 'POST'
          headers['Authorization'] = "Bearer #{@iam_token}"
          @request_helper.rest_post(url, request_body, headers)
        when 'DELETE'
          headers['Authorization'] = "Bearer #{@iam_token}"
          @request_helper.rest_delete(url, nil, headers)
        else
          raise "Invalid request type: #{request_type}"
      end
    end

    def create_batch(tenant_id, batch_template, token)
      response = hri_post_batch(tenant_id, batch_template.to_json, { 'Authorization' => "Bearer #{token}" })
      raise 'The management API failed to create a batch' unless response.code == 201
      parsed_response = JSON.parse(response.body)
      Logger.new(STDOUT).info("New Batch Created With ID: #{parsed_response['id']}")
      parsed_response['id']
    end

  end
end