require 'test_helper'

class FunctionTest < ActiveSupport::TestCase
  
  def setup
    @api_key = 'test-api-key'
    @index = 'test'

    Khoj.config do |c|
      c.api_key = @api_key
      c.api_host = Khoj::Configuration::DEFAULTS[:api_host]
    end

    @client= Khoj.client(@index)
    @function = Khoj.function(@index)
  end

  test 'should be able to map document field type to geo_type' do
    response = @function.add('geo_location', :type => 'function_test')
    sleep(1)
    assert_equal true, response
  end

end
