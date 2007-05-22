require File.dirname(__FILE__) + '/../../test_helper'
  
class Relevance::HashInitTest < Test::Unit::TestCase
  def setup
    @c = Class.new do
      attr_accessor :one, :two
      include HashInit
    end
  end
  
  def test_initialize
    inst = @c.new(:one=>1, :two=>2)
    assert_equal(1, inst.one)
    assert_equal(2, inst.two)
  end
  
  def test_empty_initialize
    assert_nothing_raised { @c.new }
  end
  
  def test_nil_initialize
    assert_nothing_raised { @c.new(nil) }
  end
  
end