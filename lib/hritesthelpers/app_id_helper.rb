module HRITestHelpers
  class AppIDHelper

    def initialize(appid_url, appid_tenant, iam_token, jwt_audience_id)
      @request_helper = RequestHelper.new
      @app_id_url = appid_url
      @appid_tenant = appid_tenant
      @iam_token = iam_token
      @jwt_audience_id = jwt_audience_id
    end

    def get_client_id_and_secret(application_name)
      response = get_applications
      raise 'Failed to get AppId applications' unless response.code == 200
      JSON.parse(response.body)['applications'].each do |application|
        if application['name'] == application_name
          return [application['clientId'], application['secret']]
        end
      end
    end

    def get_access_token(application_name, scopes, audience_override = nil)
      credentials = get_client_id_and_secret(application_name)
      response = @request_helper.rest_post("#{@app_id_url}/oauth/v4/#{@appid_tenant}/token", { 'grant_type' => 'client_credentials', 'scope' => scopes, 'audience' => (audience_override.nil? ? @jwt_audience_id : audience_override) }, { 'Content-Type' => 'application/x-www-form-urlencoded', 'Accept' => 'application/json', 'Authorization' => "Basic #{Base64.encode64("#{credentials[0]}:#{credentials[1]}").delete("\n")}" })
      raise 'App ID token request failed' unless response.code == 200
      JSON.parse(response.body)['access_token']
    end

    def get_roles(override_headers = {})
      url = "#{@app_id_url}/management/v4/#{@appid_tenant}/roles"
      headers = { 'Accept' => 'application/json',
                  'Content-Type' => 'application/json',
                  'Authorization' => "Bearer #{@iam_token}" }.merge(override_headers)
      @request_helper.rest_get(url, headers)
    end

    def get_applications(override_headers = {})
      url = "#{@app_id_url}/management/v4/#{@appid_tenant}/applications"
      headers = { 'Accept' => 'application/json',
                  'Content-Type' => 'application/json',
                  'Authorization' => "Bearer #{@iam_token}" }.merge(override_headers)
      @request_helper.rest_get(url, headers)
    end

    def get_roles_for_application(application_id, override_headers = {})
      url = "#{@app_id_url}/management/v4/#{@appid_tenant}/applications/#{application_id}/roles"
      headers = { 'Accept' => 'application/json',
                  'Content-Type' => 'application/json',
                  'Authorization' => "Bearer #{@iam_token}" }.merge(override_headers)
      @request_helper.rest_get(url, headers)
    end

    def get_scopes_for_application(application_id, override_headers = {})
      url = "#{@app_id_url}/management/v4/#{@appid_tenant}/applications/#{application_id}/scopes"
      headers = { 'Accept' => 'application/json',
                  'Content-Type' => 'application/json',
                  'Authorization' => "Bearer #{@iam_token}" }.merge(override_headers)
      @request_helper.rest_get(url, headers)
    end

    def delete_role(role_id, override_headers = {})
      url = "#{@app_id_url}/management/v4/#{@appid_tenant}/roles/#{role_id}"
      headers = { 'Accept' => 'application/json',
                  'Content-Type' => 'application/json',
                  'Authorization' => "Bearer #{@iam_token}" }.merge(override_headers)
      @request_helper.rest_delete(url, nil, headers)
    end

    def delete_application(application_id, override_headers = {})
      url = "#{@app_id_url}/management/v4/#{@appid_tenant}/applications/#{application_id}"
      headers = { 'Accept' => 'application/json',
                  'Content-Type' => 'application/json',
                  'Authorization' => "Bearer #{@iam_token}" }.merge(override_headers)
      @request_helper.rest_delete(url, nil, headers)
    end

    def get_role_id_from_name(role_name)
      response = get_roles
      raise 'Failed to get AppId roles' unless response.code == 200
      JSON.parse(response.body)['roles'].each do |role|
        if role['name'] == role_name
          return role['id']
        end
      end
      nil
    end

    def get_application_id_from_name(application_name)
      response = get_applications
      raise 'Failed to get AppId applications' unless response.code == 200
      JSON.parse(response.body)['applications'].each do |application|
        if application['name'] == application_name
          return application['clientId']
        end
      end
      nil
    end

    def verify_appid_setup(prefix, expected_setup = true)
      #Verify Roles and Applications Created
      expected_roles = ["#{prefix}HRI Consumer", "#{prefix}HRI Data Integrator", "#{prefix}HRI Internal"]
      expected_applications = ["#{prefix}HRI Internal", "#{prefix}HRI Management API"]
      roles = []
      applications = []
      response = get_roles
      raise 'Failed to get AppId roles' unless response.code == 200
      JSON.parse(response.body)['roles'].each do |role|
        roles << role['name']
      end
      response = get_applications
      raise 'Failed to get AppId applications' unless response.code == 200
      JSON.parse(response.body)['applications'].each do |application|
        applications << application['name']
        @hri_internal_id = application['clientId'] if application['name'] == "#{prefix}HRI Internal"
        @hri_mgmt_api_id = application['clientId'] if application['name'] == "#{prefix}HRI Management API"
      end
      if expected_setup
        raise 'Expected roles not created' unless (roles & expected_roles).sort == expected_roles
        raise 'Expected applications not created' unless (applications & expected_applications).sort == expected_applications
      else
        raise "Found AppId role(s), but expected none: #{roles & expected_roles}" if (roles & expected_roles).any?
        raise "Found AppId application(s), but expected none: #{applications & expected_applications}" if (applications & expected_applications).any?
      end

      if expected_setup
        #Verify Scopes assigned to applications
        response = get_scopes_for_application(@hri_internal_id)
        raise "Failed to get scopes for #{prefix}HRI Internal application" unless response.code == 200
        raise "Found scopes for #{prefix}HRI Internal application" if JSON.parse(response.body)['scopes'].any?
        response = get_scopes_for_application(@hri_mgmt_api_id)
        raise "Failed to get scopes for #{prefix}HRI Management API application" unless response.code == 200
        raise "Incorrect scopes found for #{prefix}HRI Management API application" unless JSON.parse(response.body)['scopes'].sort == %w(hri_consumer hri_data_integrator hri_internal)

        #Verify Roles assigned to applications
        roles = []
        response = get_roles_for_application(@hri_internal_id)
        raise "Failed to get roles for #{prefix}HRI Internal application" unless response.code == 200
        JSON.parse(response.body)['roles'].each do |role|
          roles << role['name']
        end
        raise "Expected roles not assigned to #{prefix}HRI Internal application" unless roles.sort == ["#{prefix}HRI Consumer", "#{prefix}HRI Internal"]
        response = get_roles_for_application(@hri_mgmt_api_id)
        raise "Failed to get roles for #{prefix}HRI Management API application" unless response.code == 200
        raise "Found roles for #{prefix}HRI Management API application" if JSON.parse(response.body)['roles'].any?
      end
    end

    def delete_appid_setup(prefix)
      roles = ["#{prefix}HRI Consumer", "#{prefix}HRI Data Integrator", "#{prefix}HRI Internal"]
      applications = ["#{prefix}HRI Internal", "#{prefix}HRI Management API"]
      roles.each do |role|
        role_id = get_role_id_from_name(role)
        delete_role(role_id) unless role_id.nil?
      end
      applications.each do |application|
        application_id = get_application_id_from_name(application)
        delete_application(application_id) unless application_id.nil?
      end
    end

  end
end