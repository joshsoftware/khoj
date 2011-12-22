module Khoj
  module Index

    def create_index
      response = @conn.put("/#{_index}")
      response.code == 200 ? true : (raise KhojException.new(response.parsed_response))
    end

    def delete_index
      response = @conn.delete("/#{_index}")
      response.code == 200 ? true : (raise KhojException.new(response.parsed_response))
    end

    def index?
      @conn.head("/#{_index}").code == 200 ? true : false 
    end

    def index_stats
      response = @conn.get("/#{_index }/_stats")
      if response.code == 200
        response.parsed_response['_all']['total']['docs']['count']
      else
        raise KhojException.new(response.parsed_response) 
      end
    end

  end
end
