require 'json'
require 'httparty'

require 'khoj/version'
require 'khoj/configuration'
require 'khoj/index'
require 'khoj/client'
require 'khoj/function'

module Khoj

  class KhojException < Exception
    def initialize(message)
      message = message['error'] if message.class == Hash
      super "[KHOJ] #{message}"
    end
  end

  def self.config(&block)
    yield Configuration

    unless Configuration.api_host
      Configuration.api_host = Configuration::DEFAULTS[:api_host]
    end

    if Configuration.api_key.nil? or Configuration.api_key.strip.empty?
      Configuration.valid = false
      raise KhojException.new('api key is nil.')
    end

    Configuration.valid = true
    #Configuration.freeze
  end

  @@clients = {} 

  def self.client(index)
    @@clients[index] ||= Client.new(index)
  end

  @@functions = {}
  
  def self.function(index)
    @@functions[index] ||= Function.new(index)
  end



end
