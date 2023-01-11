module HRITestHelpers
  class COSHelper

    def initialize(cos_url, iam_cloud_url, cloud_api_key)
      @request_helper = RequestHelper.new
      @cos_url = cos_url
      @iam_token = IAMHelper.new(iam_cloud_url).get_access_token(cloud_api_key)
    end

    def upload_object_data(bucket_name, object_path, object)
      response = @request_helper.rest_put("#{@cos_url}/#{bucket_name}/#{object_path}", object, { 'Authorization' => "Bearer #{@iam_token}" })
      raise 'Failed to upload object to COS' unless response.code == 200
    end

  end
end