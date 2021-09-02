module HRITestHelpers
  class IAMHelper

    def initialize(iam_cloud_url)
      @request_helper = RequestHelper.new
      @iam_cloud_url = iam_cloud_url
    end

    def get_access_token(cloud_api_key)
      response = @request_helper.rest_post("#{@iam_cloud_url}/identity/token", { 'grant_type' => 'urn:ibm:params:oauth:grant-type:apikey', 'apikey' => cloud_api_key }, { 'Content-Type' => 'application/x-www-form-urlencoded', 'Accept' => 'application/json' })
      raise 'IAM token request failed' unless response.code == 200
      JSON.parse(response.body)['access_token']
    end

  end
end