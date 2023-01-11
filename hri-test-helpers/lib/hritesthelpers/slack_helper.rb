module HRITestHelpers
  class SlackHelper

    def initialize(slack_webhook)
      @request_helper = RequestHelper.new
      @slack_url = slack_webhook
    end

    def send_slack_message(test_type, travis_build_dir, travis_branch, travis_job_web_url)
      message = {
        text: "*#{test_type} Test Failure:*
              Repository: #{travis_build_dir.split('/').last},
              Branch: #{travis_branch},
              Time: #{Time.now.strftime("%m/%d/%Y %H:%M")},
              Build Link: #{travis_job_web_url.gsub('https:///', 'https://travis.ibm.com/')}"
      }.to_json
      @request_helper.rest_post(@slack_url, message)
    end

  end
end