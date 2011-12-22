require 'test_helper'

class ClientTest < ActiveSupport::TestCase
  def setup
    @api_key = 'test-api-key'
    @index = 'test'

    Khoj.config do |c|
      c.api_key = @api_key
      c.api_host = Khoj::Configuration::DEFAULTS[:api_host]
    end

    @client = Khoj.client(@index)
    @document = {:test => 'from the the test case'}
  end

  def teardown
     @client.delete('test:1') rescue ''
     @client.delete('1') rescue ''
  end

  test 'should be able to add document' do
    response = @client.add('test:1', @document)
    assert_equal true, response
  end

  test 'should be able to add document to default document type' do
    response = @client.add('1', @document) # like doc id 'default:1'
    assert_equal true, response
  end

  test 'should be able to add document with default text field if string is input' do
    response = @client.add('1', 'test for default text field')
    assert_equal true, response
  end

  test 'should be able to retrive docuemt' do
    @client.add('test:1', @document)
    response = @client.get('test:1')

    assert_equal true, response['exists']
  end

  # default:1 : type => default, id => 1 
  test 'should be able to retrive default type document' do
    @client.add('1', @document)
    response = @client.get('1')

    assert_equal true, response['exists']
    assert_equal Khoj::Client::DEFAULT_DOC_TYPE, response['_type']
  end

  test 'should be able to delete document' do
    @client.add('test:1', @document)
    response = @client.delete('test:1')
    assert_equal true, response
  end

  test 'should be able to delete default type document' do
    @client.add('1', @document)
    response = @client.delete('1')
    assert_equal true, response
  end

  #Default doc type : 'default', Default filed : text
  test 'should be able to search document using default type and field' do
    @client.delete(100)
    @client.add(100, 'xxx yyy zzz')
    sleep(1)

    response = @client.search('xxx')
    assert_equal 1, response['hits']['total'] 
  end

  test 'should be able to search document using field name' do
    @client.delete('test:2') rescue ''
    @client.add('test:2', {:test => 'test2'})

    response = @client.search('test2', {:field => 'test'})
    assert_equal 1, response['hits']['total'] 
  end

  test 'should be able to search document by type' do
    @client.delete('test:3') rescue ''
    @client.add('test:3', {:test => 'test3'})

    response = @client.search('test3', {:field => 'test', :type => 'test'})
    assert_equal 1, response['hits']['total'] 
  end
end
