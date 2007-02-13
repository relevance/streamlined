$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'rubygems'
require 'test/unit'
gem 'rails'
require 'active_record'
require 'action_controller'
require 'action_controller/test_process'
require 'active_support/breakpoint'
require 'flexmock'
silence_stream(STDERR) do
  RAILS_ROOT = File.join(File.dirname(__FILE__), '../faux_rails_root')
  logfile = File.join(File.dirname(__FILE__), '../log/test.log')
  (RAILS_DEFAULT_LOGGER = Logger.new(logfile)).level = Logger::INFO
end
require 'initializer'
require "#{File.dirname(__FILE__)}/../init"

class Test::Unit::TestCase
  def assert_difference(object, method = nil, difference = 1)
    initial_value = object.send(method)
    yield
    assert_equal initial_value + difference, object.send(method), "#{object}##{method}"
  end

  def assert_no_difference(object, method, &block)
    assert_difference object, method, 0, &block
  end
end

