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
      search_uri = options[:type] ? "#{options[:type]}/_search" : '_search'
      
      # check that if search string contains AND, OR or NOT in query
      # if it is then we will execute String query of Query DSL
      # else we will execute normal search query
      if query.scan(/\sAND|NOT|OR+\s/).empty?
        options[:field] ||= DEFAULT_DOC_FIELD
        q = {:query => 
          {:term => { options[:field] => query}}
        }
        q[:query][:fields] ||= ['_id' , '_type']
        q[:query][:size] ||= (options[:size] ? (options[:size] > 10 ? DEFAULT_SEARCH_LIMIT : options[:size]) : DEFAULT_SEARCH_LIMIT)
        q[:query] = q[:query].merge(:script_fields => { "#{options[:fetch]}" => { :script => "_source.#{options[:fetch]}"}}) if options[:fetch]
      else
        
        # TODO : implement functionality for fetch action if specified by user to fetch fields from result set
        q = get_string_query(query, options)
      end
      
      facet_filter = options[:category_filter]
      unless facet_filter == nil
        facet_field = facet_filter.keys.first.to_s
        q.merge!(:facets => {facet_field => {:terms => {:field => facet_field}, :facet_filter => {:term => facet_filter}}}) 
      end

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

    def get_string_query(query, options)
      q = {:query => 
                {:query_string => { 
                                  :query => query
                                  }
                }
           }

      # while using string query default field in elastic search is _all 
      # if user specify fields then
      #  if fields contains only one 1 field/word then pass it as 'default_field' parameter
      #  if fields has more than 1 fields/words then pass them as 'fields' parameter
      fields = options[:fields].split(',').each do |i| i.strip! end  if options[:fields]
      if fields
        if fields.size == 1
          q[:query][:query_string] = q[:query][:query_string].merge(:default_field => fields[0]) 
        elsif fields.size > 1
          q[:query][:query_string] = q[:query][:query_string].merge(:fields => fields) 
        end
      end
      return q
    end

  end
end
