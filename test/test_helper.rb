$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'rubygems'
require 'test/unit'
require 'flexmock/test_unit'
require 'ostruct'
gem 'rails'
require 'active_record'
require 'action_controller'
require 'action_controller/test_process'
require 'active_support/breakpoint'
require "#{File.dirname(__FILE__)}/flexmock_patch"
require 'generator'
# Arts plugin from http://glu.ttono.us/articles/2006/05/29/guide-test-driven-rjs-with-arts
# Arts provides an easily understandable syntax for testing RJS templates
require "#{File.dirname(__FILE__)}/arts"

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

(ActiveRecord::Base.logger = RAILS_DEFAULT_LOGGER).level = Logger::DEBUG

class Test::Unit::TestCase
  include Relevance::RailsAssertions
  include Arts   

  def assert_difference(object, method = nil, difference = 1)
    initial_value = object.send(method)
    yield
    assert_equal initial_value + difference, object.send(method), "#{object}##{method}"
  end
  
  def root_node(html) 
     HTML::Document.new(html).root
  end           

  def assert_no_difference(object, method, &block)
    assert_difference object, method, 0, &block
  end
  
  def assert_equal_sets(a,b,*args)
    assert_equal(Set.new(a), Set.new(b),*args)
  end
  
  # Note that streamlined hashes should be indifferent between keys and strings
  def assert_key_set(keys, hash)
    assert_kind_of(HashWithIndifferentAccess, hash)
    assert_equal(Set.new(keys), Set.new(hash.symbolize_keys.keys))
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

