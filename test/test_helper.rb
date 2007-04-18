$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'rubygems'
require 'test/unit'
require 'flexmock/test_unit'
gem 'rails'
require 'active_record'
require 'action_controller'
require 'action_controller/test_process'
require 'active_support/breakpoint'
require "#{File.dirname(__FILE__)}/flexmock_patch"
require 'generator'

silence_stream(STDERR) do
  RAILS_ROOT = Pathname.new(File.join(File.dirname(__FILE__), '../faux_rails_root')).expand_path.to_s
  logfile = File.join(File.dirname(__FILE__), '../log/test.log')
  (RAILS_DEFAULT_LOGGER = Logger.new(logfile)).level = Logger::INFO
end
require 'initializer'
require "#{File.dirname(__FILE__)}/../init"
# must come after require init
require 'relevance/rails_assertions'
require 'relevance/controller_test_support'

class Test::Unit::TestCase
  include Relevance::RailsAssertions
  def assert_difference(object, method = nil, difference = 1)
    initial_value = object.send(method)
    yield
    assert_equal initial_value + difference, object.send(method), "#{object}##{method}"
  end

  def assert_no_difference(object, method, &block)
    assert_difference object, method, 0, &block
  end
  
  def assert_equal_sets(a,b)
    assert_equal(Set.new(a), Set.new(b))
  end
  
  def assert_enum_of_same(expected, actual)
    g = Generator.new(actual)
    expected.each do |e|
      assert_same(e,g.next)
    end
    assert_equal false, g.next?, "actual enumeration larger than expected"
  end
  
  def assert_has_private_methods(inst, *methods)
    methods.each do |method|
      method = method.to_s
      assert(inst.private_methods.member?(method), "#{method} should be private on #{inst.class}")
    end
  end

  def assert_has_public_methods(inst, *methods)
    methods.each do |method|
      method = method.to_s
      assert(inst.public_methods.member?(method), "#{method} should be public on #{inst.class}")
    end
  end
end

