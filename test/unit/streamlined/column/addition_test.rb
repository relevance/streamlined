require File.join(File.dirname(__FILE__), '../../../test_helper')
require 'streamlined/column/addition'

class Streamlined::Column::AdditionTest < Test::Unit::TestCase
  include Streamlined::Column
  
  def test_equal
    a1 = Addition.new(:foo)
    a2 = Addition.new(:foo)
    a3 = Addition.new(:bar)
    assert_equal a1, a2
    assert_not_equal a1, a3
  end
end