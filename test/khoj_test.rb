require 'test_helper'


class KhojTest < ActiveSupport::TestCase
  def setup
    @api_key = 'API-KEY'
    @api_host = 'http://testclient.com'
  end

  def teardown
  end

  test 'should init configuration' do
    Khoj.config do |c|
      c.api_key = @api_key
    end

    assert_equal @api_key, Khoj::Configuration.api_key
    assert_equal Khoj::Configuration::DEFAULTS[:api_host], Khoj::Configuration.api_host
    assert_equal true, Khoj::Configuration.valid?
  end

  test 'for nil or empty api key config should not be valid' do
    assert_raise Khoj::KhojException do
      Khoj.config do |c|
        c.api_key = nil
      end
    end

    assert_raise Khoj::KhojException do
      Khoj.config do |c|
        c.api_key = "  "
      end
    end
  end

  test 'should set api host' do
    Khoj.config do |c|
      c.api_key = @api_key
      c.api_host = @api_host 
    end

    assert_equal @api_host, Khoj::Configuration.api_host

    Khoj::Configuration.api_host = Khoj::Configuration::DEFAULTS[:api_host]
  end


  test 'should create api client' do
    api_key = 'test-api-key'
    index = 'test'
    Khoj.config do |c|
      c.api_key = api_key
      c.api_host = Khoj::Configuration::DEFAULTS[:api_host]
    end

    client = Khoj.client(index)

    assert_equal 'test', client.index
    assert_equal "#{api_key}-#{index}", client._index
  end


end
