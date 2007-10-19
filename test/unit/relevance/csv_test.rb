require File.dirname(__FILE__) + '/../../test_helper'
  
class EnumerableTest < Test::Unit::TestCase
  
  def test_array_header
    assert_equal("Upper,Normal\nA,a\nB,b\n", ['a','b'].to_csv([:upcase, :to_str], :header=>["Upper", "Normal"]))
  end
  
  def test_array_header_with_different_separator
    assert_equal("Upper;Normal\nA;a\nB;b\n", ['a','b'].to_csv([:upcase, :to_str], {:header=>["Upper", "Normal"], :separator=>";"} ))
  end
  
  def test_no_header
    assert_equal("A,a\nB,b\n", ['a','b'].to_csv([:upcase, :to_str], :header=>false))
  end
  
  def test_no_header_with_different_separator
    assert_equal("A;a\nB;b\n", ['a','b'].to_csv([:upcase, :to_str], {:header=>false, :separator=>";"} ))
  end
  
  def test_boolean_header
    assert_equal("upcase,to_str\nA,a\nB,b\n", ['a','b'].to_csv([:upcase, :to_str], :header=>true))
  end

  def test_boolean_header_with_different_separator
    assert_equal("upcase;to_str\nA;a\nB;b\n", ['a','b'].to_csv([:upcase, :to_str], {:header=>true, :separator=>";"} ))
  end

end