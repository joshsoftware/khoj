module Khoj
  class Client
    include Index

    DEFAULT_DOC_TYPE  = 'default'
    DEFAULT_DOC_FIELD = 'text'
    DEFAULT_SEARCH_LIMIT = 10

    attr_accessor :index
    attr_reader   :_index

    def initialize(index)
      @index = index
      @_index = "#{Configuration.api_key}-#{index}"
      @conn = Configuration.connection
    end

    def get(resource_id, options = {})
      response = @conn.get("/#{_index}/#{resource_type(resource_id).join('/')}")
      response.parsed_response
    end

    def add(resource_id, options = {})
      resource_name, id = resource_type(resource_id)
      resource = if options.class == String
                   return if options.strip.empty?
                   { DEFAULT_DOC_FIELD => options}
                 else
                   return if options.empty?
                   options
                 end

      req_options = {:body => resource.to_json, :format => 'json'}
      response = @conn.post("/#{_index}/#{resource_name}/#{id}", req_options)

      case response.code
      when 200
        true
      when 201
        true
      else
        raise KhojException.new(response.parsed_response)
      end
    end

    def delete(resource_id)
      response = @conn.delete("/#{_index}/#{resource_type(resource_id).join('/')}")
      response.code == 200
    end

    def search(query, options = {})
      options[:field] ||= DEFAULT_DOC_FIELD
      search_uri = options[:type] ? "#{options[:type]}/_search" : '_search'
      q = {:query => 
                {:term => { options[:field] => query}}
           }
      q[:query][:fields] ||= ['_id' , '_type']
      q[:query][:size] ||= (options[:size] ? (options[:size] > 10 ? DEFAULT_SEARCH_LIMIT : options[:size]) : DEFAULT_SEARCH_LIMIT)
      q[:query] = q[:query].merge(:script_fields => { "#{options[:fetch]}" => { :script => "_source.#{options[:fetch]}"}}) if options[:fetch]
      response = @conn.get("/#{_index}/#{search_uri}", :body => q.to_json)
      case response.code
      when 200
        response.parsed_response
      else
        nil
      end
    end

    private
    def resource_type(resource_id)
      id, resource_name =  resource_id.to_s.split(':').reverse
      return [resource_name || DEFAULT_DOC_TYPE, id]
    end

  end
end
