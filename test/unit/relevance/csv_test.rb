require File.dirname(__FILE__) + '/../../test_helper'
  
class EnumerableTest < Test::Unit::TestCase
  
  def test_array_header
    assert_equal("Upper,Normal\nA,a\nB,b\n", ['a','b'].to_csv([:upcase, :to_str], :header=>["Upper", "Normal"]))
  end
  
  def test_no_header
    assert_equal("A,a\nB,b\n", ['a','b'].to_csv([:upcase, :to_str], :header=>false))
  end
  
  def test_boolean_header
    assert_equal("upcase,to_str\nA,a\nB,b\n", ['a','b'].to_csv([:upcase, :to_str], :header=>true))
  end
end