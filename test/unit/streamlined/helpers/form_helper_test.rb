require File.join(File.dirname(__FILE__), '../../../test_helper')
require 'streamlined/helpers/form_helper'

class Streamlined::FormHelperTest < Test::Unit::TestCase
  include Streamlined::Helpers::FormHelper
  
  def test_unassigned_if_allowed_with_model_that_has_no_validations
    model_class, column = flexmock, flexmock(:unassigned_value => 'none', :name => 'name')
    model_class.should_receive(:respond_to?).with('reflect_on_validations_for').and_return(true).once
    model_class.should_receive(:reflect_on_validations_for).with('name').and_return([])
    assert_equal "<option value='nil' selected>none</option>", unassigned_if_allowed(model_class, column, nil)
  end
  
  def test_unassigned_if_allowed_with_model_that_has_validations
    model_class, column = flexmock, flexmock(:unassigned_value => 'none', :name => 'name')
    model_class.should_receive(:respond_to?).with('reflect_on_validations_for').and_return(true).once
    model_class.should_receive(:reflect_on_validations_for).with('name').and_return([flexmock(:macro => :validates_presence_of)])
    assert_equal '', unassigned_if_allowed(model_class, column, nil)
  end
  
  def test_column_can_be_unassigned_with_nils
    assert column_can_be_unassigned?(nil, nil)
  end
  
  def test_column_required_returns_false_if_validation_reflection_isnt_available
    assert_false column_required?(stub, "column_name")
  end
  
  def test_column_required_returns_false_if_validates_presence_of_is_not_present
    ar_model = stub
    ar_model.stubs(:reflect_on_validations_for).returns([])    
    assert_false column_required?(ar_model, "column_name")
  end

  def test_column_required_returns_true_if_validates_presence_of_is_present
    ar_model = stub
    ar_model.stubs(:reflect_on_validations_for).with("column_name").returns([stub(:macro => :validates_presence_of)])
    assert_true column_required?(ar_model, "column_name")
  end

  def test_column_required_returns_true_if_validates_presence_of_column_id_is_present
    ar_model = stub
    ar_model.stubs(:reflect_on_validations_for).with("column_name").returns([])
    ar_model.stubs(:reflect_on_validations_for).with("column_name_id").returns([stub(:macro => :validates_presence_of)])
    assert_true column_required?(ar_model, "column_name")
  end
end