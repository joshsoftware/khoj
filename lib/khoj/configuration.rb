module Khoj
  class Configuration
    DEFAULTS = {
      :api_host => 'http://localhost:9200'
    }

    class << self
      attr_accessor :api_key
      attr_accessor :api_host
      attr_accessor :valid

      def connection
        @connection ||= Connection.new(:url => Configuration.api_host).class
      end

      def valid?
        self.valid
      end

    end

    class Connection
      include HTTParty
      format :json

      def initialize(options = {})
        self.class.base_uri(options[:url])
      end
    end

  end
end
