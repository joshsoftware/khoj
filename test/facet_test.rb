require 'test_helper'

class FacetTest < ActiveSupport::TestCase
  def setup
    @api_key = 'test-api-key'
    @index = 'test-facet'

    Khoj.config do |c|
      c.api_key = @api_key
      c.api_host = Khoj::Configuration::DEFAULTS[:api_host]
    end

    @client = Khoj.client(@index)
    @document = {:test => 'from the the test case'}
  end

  def teardown
    @client.delete('test:1') rescue ''
    @client.delete('test:2') rescue ''
    @client.delete('test:3') rescue ''
  end

  test 'should be able to filter facet count' do
    @client.add('test:1', {:test => 'test1', :tags => ['foo']})
    @client.add('test:2', {:test => 'test2', :tags => ['baz']})
    sleep(5)   
    response = @client.search('test1', {:field => 'test', :type => 'test', :category_filter =>{'tags' => ['foo']}})
    assert_equal 1, response['facets']['tags']['total'] 
    assert_equal 1, response['hits']['total'] 
  end
  
  test 'facet count depends on search result' do
    @client.add('test:1', {:test => 'test1', :tags => ['foo']})
    @client.add('test:2', {:test => 'test2', :tags => ['foo']})
    sleep(5)   
  
    response = @client.search('test1', {:field => 'test', :type => 'test', :category_filter =>{'tags' => ['foo']}})
    
    assert_equal 1, response['facets']['tags']['total'] 
    assert_equal 1, response['hits']['total'] 
  end

  test 'should be able to filter multiple facet count' do
    @client.add('test:3', {:test => 'test3', :tags => ['foo'], :location => 'london'})
    sleep(5)   
    
    response = @client.search('test3', {:field => 'test', :type => 'test', :category_filter =>{'tags' => ['foo'], 'location' => 'london'}})
    
    assert_equal 1, response['facets']['tags']['total'] 
    assert_equal 1, response['facets']['location']['total'] 
    assert_equal 1, response['hits']['total'] 
  end

  test 'should perform AND operation on multiple value passed for single field' do
    @client.add('test:1', {:test => 'test1', :tags => ['foo'], :location => ['pune', 'mumbai', 'delhi']})
    @client.add('test:2', {:test => 'test2', :tags => ['foo'], :location => ['pune', 'mumbai']})
    sleep(5)   
  
    response = @client.search('test1', {:field => 'test', :type => 'test', :category_filter =>{'location' => ['pune', 'mumbai', 'delhi']}})
    assert_equal 3, response['facets']['location']['total'] 
    assert_equal 1, response['hits']['total'] 
  end

end
