$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'rubygems'
require 'test/unit'
require 'flexmock/test_unit'
require 'ostruct'
require File.expand_path(File.join(File.dirname(__FILE__), "multi_rails"))
require File.expand_path(File.join(File.dirname(__FILE__), "flexmock_patch"))
require 'generator'
require 'redgreen' unless Object.const_defined?("TextMate") rescue LoadError nil # dont depend on redgreen
# Arts plugin from http://glu.ttono.us/articles/2006/05/29/guide-test-driven-rjs-with-arts
# Arts provides an easily understandable syntax for testing RJS templates
require File.expand_path(File.join(File.dirname(__FILE__), "arts"))

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

if ActionController::Base.respond_to? :view_paths=
 ActionView::Base.send(:include, Streamlined::Helper)  
 ActionController::Base.view_paths = [File.join(RAILS_ROOT, 'app', 'views')]
  
 %W(#{RAILS_ROOT}/vendor/plugins/streamlined/templates
    #{RAILS_ROOT}/vendor/plugins/streamlined/templates/shared
    #{RAILS_ROOT}/vendor/plugins/streamlined/templates/generic_views
    #{RAILS_ROOT}/vendor/plugins/streamlined/templates/relationships/edit_views
    #{RAILS_ROOT}/vendor/plugins/streamlined/templates/relationships/edit_views/filter_select
    #{RAILS_ROOT}/vendor/plugins/streamlined/templates/relationships/show_views
  ).each do |path|
    ActionController::Base.append_view_path(path)
  end
end

class Test::Unit::TestCase
  include Relevance::RailsAssertions
  include Arts
  
  def root_node(html) 
     HTML::Document.new(html).root
  end
  
  def generic_view(template)
    "../../../templates/generic_views/#{template}"
  end
  
  def assert_difference(object, method = nil, difference = 1)
    initial_value = object.send(method)
    yield
    assert_equal initial_value + difference, object.send(method), "#{object}##{method}"
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

