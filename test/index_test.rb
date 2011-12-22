require 'test_helper'

class IndexTest < ActiveSupport::TestCase
  def setup
    @api_key = 'test-api-key'
    @index   = 'test'

    Khoj.config do |c|
      c.api_key = @api_key
      c.api_host = Khoj::Configuration::DEFAULTS[:api_host]
    end
  end

  def teardown    
    begin 
       client = Khoj.client(@index)
       client.delete_index
    rescue Exception => e
      ""
    end
  end

  test 'should create index. check index exist or not and delete index' do
    @index = "test_1"
    client = Khoj.client(@index)

    assert_equal true, client.create_index
    assert_equal true, client.index?
    assert_equal true, client.delete_index
  end

  test 'should throw exception on create if index already exist' do
    @index = "test_2"
    client = Khoj.client(@index)
    client.create_index 

    assert_raise Khoj::KhojException do
      client.create_index
    end
  end

  test 'should throw exception on delete if index not exist' do
    @index = "test_3"
    client = Khoj.client(@index)

    assert_raise Khoj::KhojException do
      client.delete_index
    end
  end

  test 'should return index state' do
    @index = "test_4"
    client = Khoj.client(@index)
    client.create_index

    assert_equal 0, client.index_stats
  end

  test 'index name should be in lower case' do
    @index = "TEST-INDEX"
    client = Khoj.client(@index)

    assert_raise Khoj::KhojException do
      client.create_index
    end
  end

end
