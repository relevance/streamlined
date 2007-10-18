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
  
  def test_single_format_for_display
    format_gandalf_for_display
  end                               
  
  def test_single_format_for_edit
    format_voldemort_for_edit
  end
  
  def test_multiple_formats
    format_gandalf_for_display
    format_fingolfin_for_display      
    format_voldemort_for_edit
  end
  
  def test_reset_formats
    format_gandalf_for_display
    format_fingolfin_for_display
    format_voldemort_for_edit
    Streamlined::PermanentRegistry.reset
    assert_equal "Gandalf", Streamlined.format_for_display("Gandalf")
    assert_equal "Fingolfin", Streamlined.format_for_display("Fingolfin")
    assert_equal "Voldemort", Streamlined.format_for_edit("Voldemort")
  end
  
  def test_should_return_true_for_edge_rails_if_edge_rails_features_are_present
    ActionController::Base.expects(:respond_to?).with(:view_paths=).returns(true)
    assert Streamlined.edge_rails?
  end
  
  def test_should_return_false_for_edge_rails_if_edge_rails_features_are_present
    ActionController::Base.expects(:respond_to?).with(:view_paths=).returns(false)
    assert_false Streamlined.edge_rails?
  end
  
  private 
  
  def format_gandalf_for_display
    assert_equal "Gandalf", Streamlined.format_for_display("Gandalf")
    Streamlined.display_format_for("Gandalf") do |obj|
      "#{obj} is a wizard!"
    end
    assert_equal "Gandalf is a wizard!", Streamlined.format_for_display("Gandalf")
  end
  
  def format_fingolfin_for_display
    assert_equal "Fingolfin", Streamlined.format_for_display("Fingolfin")
    Streamlined.display_format_for("Fingolfin") do |obj|
      "#{obj} is an elf!"
    end
    assert_equal "Fingolfin is an elf!", Streamlined.format_for_display("Fingolfin")
  end
  
  def format_voldemort_for_edit
    assert_equal "Voldemort", Streamlined.format_for_edit("Voldemort")
    Streamlined.edit_format_for("Voldermort") do |obj|
      "He Who Must Not Be Named"
    end
    assert_equal "He Who Must Not Be Named", Streamlined.format_for_edit("Voldermort")
  end
  
  
end