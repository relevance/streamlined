require File.join(File.dirname(__FILE__), '../../test_functional_helper')
require 'streamlined/reflection'

class Streamlined::ReflectionTest < Test::Unit::TestCase
  include Streamlined::Reflection
  attr_accessor :model
  
  def test_reflect_on_scalars
    self.model=Person
    hash = reflect_on_scalars
    assert_equal(Set.new([:id,:first_name,:last_name]), Set.new(hash.keys))
  end
  
  def test_reflect_on_additions
    self.model=Person
    hash = reflect_on_additions
    assert_equal(Set.new([:full_name]), Set.new(hash.keys))
  end
  
  def test_reflect_on_relationships
    self.model=Poet
    hash = reflect_on_relationships
    assert_equal(Set.new([:poems]), Set.new(hash.keys))
    hash.each do |k,v|
      assert_equal k, v.name
    end
  end
  
end