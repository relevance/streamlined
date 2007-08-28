require File.join(File.dirname(__FILE__), '/../test_helper')

class StreamlinedTest < Test::Unit::TestCase
       
  def setup
    Streamlined::PermanentRegistry.reset
  end                          
  
  def teardown
    Streamlined::PermanentRegistry.reset
  end
                  
  def test_bad_format
    error = assert_raises(ArgumentError) {Streamlined.display_format_for("Forgot proc argument")}
    assert_equal "Block required", error.message
  end
  
  def test_single_format
    format_gandalf
  end
  
  def test_multiple_formats
    format_gandalf
    format_fingolfin
  end
  
  def test_reset_formats
    format_gandalf
    format_fingolfin
    Streamlined::PermanentRegistry.reset
    assert_equal "Gandalf", Streamlined.format_for_display("Gandalf")
    assert_equal "Fingolfin", Streamlined.format_for_display("Fingolfin")
  end
  
  def format_gandalf
    assert_equal "Gandalf", Streamlined.format_for_display("Gandalf")
    Streamlined.display_format_for("Gandalf") do |obj|
      "#{obj} is a wizard!"
    end
    assert_equal "Gandalf is a wizard!", Streamlined.format_for_display("Gandalf")
  end
  
  def format_fingolfin
    assert_equal "Fingolfin", Streamlined.format_for_display("Fingolfin")
    Streamlined.display_format_for("Fingolfin") do |obj|
      "#{obj} is an elf!"
    end
    assert_equal "Fingolfin is an elf!", Streamlined.format_for_display("Fingolfin")
  end
end