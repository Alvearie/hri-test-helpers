module HRITestHelpers
  class AzureReusableFunctions

    def initialize
      @request_helper = RequestHelper.new

    end

    def mongo_connection(mongodb_credentials = {})
      @headers = { 'Content-Type': 'application/json' }
      client = Mongo::Client.new('mongodb://hi-dp-tst-eastus-cosmos-mongo-api-hri:Jl6rN2wUFpROlr4Cxse61ET51TB1qwZTZXfD1IwotXQKUBUaEGjBXr8DqKAKonhBkhwSxdLIkJitZUE9X2liSg==@hi-dp-tst-eastus-cosmos-mongo-api-hri.mongo.cosmos.azure.com:10255/?ssl=true&replicaSet=globaldb&retrywrites=false&maxIdleTimeMS=120000&appName=@hi-dp-tst-eastus-cosmos-mongo-api-hri@' , :database => 'HRI-DEV')
      db = client.database
      collection = client[:'HRI-Mgmt']
      # puts collection.find( { tenantid: 'q-batches' } ).first
    end

    def fetch_client_id_and_secret
      %w[c33ac4da-21c6-426b-abcc-27e24ff1ccf9 GxF8Q~XfZyLRQBZ4mjwgEogVWwGjtzJh7ZPzgagw]
    end

    def generate_access_token
      credentials = fetch_client_id_and_secret
      response = @request_helper.rest_post("https://login.microsoftonline.com/ceaa63aa-5d5c-4c7d-94b0-02f9a3ab6a8c/oauth2/v2.0/token",{'grant_type' => 'client_credentials','scope' => 'c33ac4da-21c6-426b-abcc-27e24ff1ccf9/.default', 'client_secret' => 'GxF8Q~XfZyLRQBZ4mjwgEogVWwGjtzJh7ZPzgagw', 'client_id' => 'c33ac4da-21c6-426b-abcc-27e24ff1ccf9'}, {'Content-Type' => 'application/x-www-form-urlencoded', 'Accept' => 'application/json', 'Authorization' => "Basic #{Base64.encode64("#{credentials[0]}:#{credentials[1]}").delete("\n")}" })
      raise 'App ID token request failed' unless response.code == 200

      # puts "This is the generated token ==============================>  "
      # puts JSON.parse(response.body)['access_token']
      JSON.parse(response.body)['access_token']
    end



  end
end
