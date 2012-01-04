require 'test_helper'

class FunctionTest < ActiveSupport::TestCase
  
  def setup
    @api_key = 'test-api-key'
    @index = 'new_test'

    Khoj.config do |c|
      c.api_key = @api_key
      c.api_host = Khoj::Configuration::DEFAULTS[:api_host]
    end

    @client= Khoj.client(@index)
    @function = Khoj.function(@index)
    @document = {:test => 'new_test'}
  end

  test 'should be able to sort document according to location in ascending order' do
    @client.add('new_test:1', :text => 'new_test', :location => {:lat => '100.00', :lon => "100.00"})
    @client.add('new_test:2', :text => 'new_test', :location => {:lat => '50.00', :lon => "50.00"})
    @client.add('new_test:3', :text => 'new_test', :location => {:lat => '00.00', :lon => "00.00"})
    response = @client.search 'new_test', :function => {:cordinates => "100,100", :order => 'asc', :name => 'geo_location'}, :size => 3, :type => 'new_test'
    sleep(1)
    assert_equal "1", response["hits"]["hits"][0]["_id"]
    assert_equal "3", response["hits"]["hits"][1]["_id"]
    assert_equal "2", response["hits"]["hits"][2]["_id"]
  end

  test 'should be able to sort document according to location in descending order' do
    @client.add('new_test:1', :text => 'new_test', :location => {:lat => '100.00', :lon => "100.00"})
    @client.add('new_test:2', :text => 'new_test', :location => {:lat => '50.00', :lon => "50.00"})
    @client.add('new_test:3', :text => 'new_test', :location => {:lat => '00.00', :lon => "00.00"})
    response = @client.search 'new_test', :function => {:cordinates => "100,100", :order => 'desc', :name => 'geo_location'}, :size => 3, :type => 'new_test'
    sleep(1)
    assert_equal "2", response["hits"]["hits"][0]["_id"]
    assert_equal "3", response["hits"]["hits"][1]["_id"]
    assert_equal "1", response["hits"]["hits"][2]["_id"]
  end
  
  test 'should be able to map document field type to geo_type' do
    response = @function.add('geo_location', :type => 'new_test')
    sleep(1)
    assert_equal true, response
  end

end
