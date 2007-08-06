require File.join(File.dirname(__FILE__), '../../test_functional_helper')
require 'streamlined/reflection'

class Streamlined::ReflectionTest < Test::Unit::TestCase
  include Streamlined::Reflection
  attr_accessor :model
  
  def setup
    Streamlined::Registry.reset
  end
  
  def test_reflect_on_scalars
    self.model=Person
    hash = reflect_on_scalars
    assert_key_set([:id,:first_name,:last_name], hash)
  end
  
  def test_reflect_on_additions
    self.model=Person
    hash = reflect_on_additions
    assert_key_set([:full_name], hash)
  end
  
  def test_reflect_on_relationships
    self.model=Poet
    hash = reflect_on_relationships
    assert_key_set([:poems], hash)
    hash.each do |k,v|
      assert_equal k.to_s, v.name.to_s
    end
  end
  
  def test_reflect_on_delegates_dups_columns_from_associations
    self.model = Poem
    hash = reflect_on_delegates
    assert_not_same hash["first_name"], Streamlined.ui_for(Poet).column(:first_name)
  end
end