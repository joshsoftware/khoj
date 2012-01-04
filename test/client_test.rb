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
    @client.delete('1') rescue ''
    5.times do |i|
      @client.delete("test:#{i+1}") rescue ''
    end
  end

  test 'should be able to add document' do
    response = @client.add('test:1', @document)
    sleep(1)
    assert_equal true, response
  end

  test 'should be able to add document to default document type' do
    response = @client.add('1', @document) # like doc id 'default:1'
    sleep(1)
    assert_equal true, response
  end

  test 'should be able to add document with default text field if string is input' do
    response = @client.add('1', 'test for default text field')
    sleep(1)
    assert_equal true, response
  end

  test 'should be able to retrive docuemt' do
    @client.add('test:1', @document)
    sleep(1)
    response = @client.get('test:1')

    assert_equal true, response['exists']
  end

  # default:1 : type => default, id => 1 
  test 'should be able to retrive default type document' do
    @client.add('1', @document)
    sleep(1)
    response = @client.get('1')

    assert_equal true, response['exists']
    assert_equal Khoj::Client::DEFAULT_DOC_TYPE, response['_type']
  end

  test 'should be able to delete document' do
    @client.add('test:1', @document)
    sleep(1)
    response = @client.delete('test:1')
    assert_equal true, response
  end

  test 'should be able to delete default type document' do
    @client.add('1', @document)
    sleep(1)
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
    @client.add('test:2', {:test => 'test2'})
    sleep(1)

    response = @client.search('test2', {:field => 'test'})
    assert_equal 1, response['hits']['total'] 
  end

  test 'should be able to search document by type' do
    @client.add('test:3', {:test => 'test3'})
    sleep(1)

    response = @client.search('test3', {:field => 'test', :type => 'test'})
    assert_equal 1, response['hits']['total'] 
  end

  #size
  test 'should be able to search number of records as size is specified, 10 by default' do
    15.times do |i|
      @client.add("test:#{i+1}",  'test application')
    end
    sleep(1)
    response = @client.search('test', :size => 0)
    assert_equal 0, response['hits']['hits'].count

    response = @client.search('test', :size => 5)
    assert_equal 5, response['hits']['hits'].count 

    response = @client.search('test')
    assert_equal 10, response['hits']['hits'].count 

    response = @client.search('test', :size => 15)
    assert_equal 10, response['hits']['hits'].count 

    6.times do |i|
      @client.delete("test:#{i+1}") rescue ''
    end
    sleep(1)

    response = @client.search('test')
    assert_equal 9, response['hits']['hits'].count

    response = @client.search('test', :size => 10)
    assert_equal 9, response['hits']['hits'].count 

    15.times do |i|
      @client.delete("test:#{i+1}") rescue ''
    end
  end
  
  test 'should fetch specified field from documents from which search match is found, if not present then should return nil' do
    field = 'designation'
    designation = 'Software Engineer'
  
    # matching text 'software' with designation
    @client.add('test:1', :text => 'I am a software engineer', :location => 'Pune', :designation => designation)
  
    # matching text without designation
    @client.add('test:2', :text => 'I am a freelancer who developes software', :location => 'Mumbai')
  
    #unmatching text with designation
    @client.add('test:3', :text => 'I do marketing of products', :location => 'Delhi', :designation => 'Marketing Executive')
    sleep(1)
  
    response = @client.search('software', :fetch=> field)

    ids = [] # ids array will contain ids of documents 
    fields = []  # fields array will contain fetched fields, each field is in key => value format such as "fields"=>{"designation"=>"Software Engineer"}
    field_values = [] # fields_values will contain values of fetched fields such as 'Software Engineer','Marketing Executive',nil etc.

    # Data received in json format is,
    # {
    #   "took"=>5, "timed_out"=>false, "_shards"=>{"total"=>5, "successful"=>5, "failed"=>0}, 
    #   "hits"=>{"total"=>2, "max_score"=>0.15342641, 
    #            "hits"=>[
    #                     {"_index"=>"test-api-key-test", "_type"=>"test", "_id"=>"1", "_score"=>0.15342641, "fields"=>{"designation"=>"Software Engineer"}}, 
    #                     {"_index"=>"test-api-key-test", "_type"=>"test", "_id"=>"2", "_score"=>0.11506981, "fields"=>{"designation"=>nil}}
    #                    ]
    #           }
    # }

    response['hits']['hits'].each do |i|
      ids << i['_id']
      fields << i['fields']
      field_values << i['fields'].values
    end
    field_values.flatten!
    # as per data entered, hits should be 2 as word 'software' is in only 2 documents
    assert_equal 2, response['hits']['total']

    # fields array should contain uniq element as only one field is fetched  
    assert_equal 1, fields.collect(&:keys).flatten.uniq.count

    # key of every element in fields array should be 'designation'
    assert_equal field, fields.collect(&:keys).flatten.uniq.first

    # ids array should contain 1 and 2, not 3
    assert_equal true, ids.include?('1')
    assert_equal true, ids.include?('2')
    assert_equal false, ids.include?('3')

    # Designation value should be 
    # software enginner for document test:1 and nil for test:2
    # it should not contain value as Marketing Executive
    assert_equal true, field_values.include?(designation)
    assert_equal true, field_values.include?(nil)
    assert_equal false, field_values.include?('Marketing Executive')

  end

  test 'should perofrm search operation using operators[AND/OR/NOT], when no field specified, default is all fields' do
    add_data_with_multiple_fields

    # Search data with operators using no fields specified 
    response = @client.search('marketing OR tester')
    ids = get_ids_from_response(response)
    assert_equal 2, ids.size
    assert_equal true, ids.include?('3')
    assert_equal true, ids.include?('4')
  end

  test 'should perofrm operations using operators, when single field is specified' do
    add_data_with_multiple_fields
    # Search data with operators and within single field
    response = @client.search('delhi OR mumbai', :fields => "location")
    ids = get_ids_from_response(response)
    assert_equal 2, response['hits']['total']
    assert_equal true, ids.include?('2')
    assert_equal true, ids.include?('3')
    
    response = @client.search('tester OR pune', :fields => "text")
    assert_equal 0, response['hits']['total']
  end

  test 'should perofrm operations using operators, when multiple fields are specified' do
    add_data_with_multiple_fields
    # Search data with operators and with multiple fields
    response = @client.search('software AND mumbai', :fields => "designation, location")
    assert_equal 1, response['hits']['total']
    assert_equal '2', response['hits']['hits'].first['_id']

    response = @client.search('software OR pune NOT tester NOT manager NOT mumbai', :fields => "designation, location")
    assert_equal 1, response['hits']['total']
    assert_equal '1', response['hits']['hits'].first['_id']
  end

  def add_data_with_multiple_fields
    # While changig data in this method make sure to do changed in all respective places as the data fields are used for validation of test cases
    @client.add('test:1', :text => 'I am a software engineer', :location => 'Pune', :designation => 'Software engineer')
    @client.add('test:2', :text => 'I am a freelancer who developes software', :location => 'Mumbai', :designation => 'Senior Software Engineer')
    @client.add('test:3', :text => 'I do marketing of products', :location => 'Delhi', :designation => 'Marketing Executive')
    @client.add('test:4', :text => 'I test the product', :location => 'Pune, University Road', :designation => 'Tester')
    @client.add('test:5', :text => 'I manage the company', :location => 'Pune, Shivajinagar', :designation => 'Manager')
    sleep(1)
  end

  def get_ids_from_response(response)
    ids = []
    response['hits']['hits'].each do |i|
      ids << i['_id']
    end
    return ids
  end
end
