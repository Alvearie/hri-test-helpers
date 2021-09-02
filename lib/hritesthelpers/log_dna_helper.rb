module HRITestHelpers
  class LogDnaHelper

    def initialize(logdna_url, logdna_ingestion_key, host_name, app_name)
      @request_helper = RequestHelper.new
      @base_url = logdna_url
      @host_name = host_name
      @app_name = app_name
      @basic_auth = {user: logdna_ingestion_key, password: ''}
    end

    def log_message(msg, level = 'INFO')
      body = {
        lines: [
          {
            line: msg,
            app: @app_name,
            level: level
          }
        ]
      }.to_json
      headers = {'charset' => 'UTF-8',
                 'Content-Type' => 'application/json'}
      @request_helper.rest_post("#{@base_url}?hostname=#{@host_name}", body, headers, @basic_auth)
    end

  end
end