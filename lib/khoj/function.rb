module Khoj
  class Function
    include Index

    attr_accessor :index
    attr_reader   :_index

    def initialize(index)
      @index = index
      @_index = "#{Configuration.api_key}-#{index}"
      @conn = Configuration.connection
    end

    def add(funtion_name, options ={})
      type = options[:type]
      if funtion_name == 'geo_location' 
        geo_mapping =  { "#{type}" => { "properties" => { "location" => { "type" => "geo_point" } } } }
        req_options = {:body => geo_mapping.to_json, :format => 'json'}
        response = @conn.post("/#{_index}/#{type}/_mapping", req_options)
        case response.code
        when 200
          true
        when 201
          true
        else
          raise KhojException.new(response.parsed_response)
        end
      else
          raise KhojException.new('No function found with given name')
      end
    end

  end
end

