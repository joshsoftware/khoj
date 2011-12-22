require 'test/unit'
require 'active_support/test_case'

unless $LOAD_PATH.include? 'lib'
  $LOAD_PATH.unshift(File.dirname(__FILE__))
  $LOAD_PATH.unshift(File.join($LOAD_PATH.first, '..', 'lib'))
end

#NOTE: rake test TEST=test.rb 

require 'khoj' 
