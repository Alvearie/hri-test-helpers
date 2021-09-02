module HRITestHelpers
  class ElasticHelper

    def initialize(elastic_credentials = {})
      @request_helper = RequestHelper.new
      @elastic_url = elastic_credentials[:url]
      @headers = { 'Content-Type': 'application/json' }
      @basic_auth = { user: elastic_credentials[:username], password: elastic_credentials[:password] }
    end

    def es_get_batch(index, batch_id)
      @request_helper.rest_get("#{@elastic_url}/#{index}-batches/_doc/#{batch_id}", @headers, @basic_auth)
    end

    def es_create_batch(index, batch_info)
      @request_helper.rest_post("#{@elastic_url}/#{index}-batches/_doc?refresh=wait_for", batch_info, @headers, @basic_auth)
    end

    def es_delete_batch(index, batch_id)
      @request_helper.rest_delete("#{@elastic_url}/#{index}-batches/_doc/#{batch_id}", nil, @headers, @basic_auth)
    end

    def es_delete_by_query(index, query)
      @request_helper.rest_post("#{@elastic_url}/#{index}-batches/_delete_by_query?q=#{query}", nil, @headers, @basic_auth)
    end

    def es_batch_update(index, batch_id, script)
      # wait_for waits for an index refresh to happen, so increase the standard timeout
      @request_helper.rest_post("#{@elastic_url}/#{index}-batches/_doc/#{batch_id}/_update?refresh=wait_for", script, @headers, @basic_auth.merge({ timeout: 120 }))
    end

    def delete_index(index)
      @request_helper.rest_delete("#{@elastic_url}/#{index}-batches", nil, @headers, @basic_auth)
    end

    def es_get_index_template(template_name)
      @request_helper.rest_get("#{@elastic_url}/_index_template/#{template_name}", @headers, @basic_auth)
    end

    def es_delete_index_template(template_name)
      @request_helper.rest_delete("#{@elastic_url}/_index_template/#{template_name}", nil, @headers, @basic_auth)
    end
  end
end