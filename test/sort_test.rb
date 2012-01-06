require 'test_helper'

class SortTest < ActiveSupport::TestCase
  
  def setup
    @api_key = 'test-api-key-new'
    @index = 'test-new'

    Khoj.config do |c|
      c.api_key = @api_key
      c.api_host = Khoj::Configuration::DEFAULTS[:api_host]
    end

    @client= Khoj.client(@index)
    @function = Khoj.function(@index)
    @function.add('geo_location', :type => 'sort_test')
    @client.add('sort_test:1', :text => 'sort_test', :location => {:lat => '100.00', :lon => "100.00"}, :price => '100' ,:range => '200')
    @client.add('sort_test:2', :text => 'sort_test', :location => {:lat => '50.00', :lon => "50.00"}, :price => '200', :range => '100')
    @client.add('sort_test:3', :text => 'sort_test', :location => {:lat => '00.00', :lon => "00.00"}, :price => '300', :range => '100')
    sleep(5)
  end
  
  def teardown
    
  end

  test 'should be able to sort document according to location in ascending order' do
    response = @client.search 'sort_test', :sort => {:geo_location => {:cordinates => "100,100", :order => 'asc'}}, :size => 3, :type => 'sort_test'
    assert_equal "1", response["hits"]["hits"][0]["_id"]
    assert_equal "3", response["hits"]["hits"][1]["_id"]
    assert_equal "2", response["hits"]["hits"][2]["_id"]
  end

  test 'should be able to sort document according to location in descending order' do
    response = @client.search 'sort_test', :sort => {:geo_location => {:cordinates => "100,100", :order => 'desc'}}, :size => 3, :type => 'sort_test'
    assert_equal "2", response["hits"]["hits"][0]["_id"]
    assert_equal "3", response["hits"]["hits"][1]["_id"]
    assert_equal "1", response["hits"]["hits"][2]["_id"]
  end

  test 'should be able to sort document according price range' do
    response = @client.search 'sort_test', :sort => {:fields => {:price => "asc"}}, :size => 3, :type => 'sort_test'
    assert_equal "1", response["hits"]["hits"][0]["_id"]
    assert_equal "2", response["hits"]["hits"][1]["_id"]
    assert_equal "3", response["hits"]["hits"][2]["_id"]
  end
  
  test 'should be able to sort document primarily by range and then price range' do
    response = @client.search 'sort_test', :sort => {:fields => {:range => 'desc', :price => "desc"}}, :size => 3, :type => 'sort_test'
    assert_equal "1", response["hits"]["hits"][0]["_id"]
    assert_equal "3", response["hits"]["hits"][1]["_id"]
    assert_equal "2", response["hits"]["hits"][2]["_id"]
  end
  
end
