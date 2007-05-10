require File.join(File.dirname(__FILE__), '../../../test_helper')
require 'streamlined/column/addition'

class Streamlined::Column::AdditionTest < Test::Unit::TestCase
  include Streamlined::Column
  
  def setup
    @addition = Addition.new(:foo_bar, nil)
  end
  
  def test_equal
    a1 = @addition
    a2 = Addition.new(:foo_bar, nil)
    a3 = Addition.new(:bar, nil)
    assert_equal a1, a2
    assert_not_equal a1, a3
  end
  
  def test_name
    assert_equal 'foo_bar', @addition.name
  end
  
  def test_human_name
    assert_equal 'Foo bar', @addition.human_name
  end
  
  def test_read_only_defaults_to_true
    assert @addition.read_only
  end
end