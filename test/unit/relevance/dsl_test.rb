require File.join(File.dirname(__FILE__), "../../test_helper")
require 'relevance/dsl'

module Relevance
  class DslTest < Test::Unit::TestCase
    class Test
      dsl_scalar :my_scalar
      dsl_array :my_array
    end

    def test_scalar
      t = Test.new
      assert_nil t.my_scalar
      assert_same :someval, t.my_scalar(:someval)
      assert_same :someval, t.my_scalar
    end

    def test_array
      t = Test.new
      assert_equal [], t.my_array
      assert_equal [1,2], t.my_array(1,2)
      assert_equal [1,2,3], t.my_array(3)
      assert_equal [1,2,3], t.my_array
    end
  end
end