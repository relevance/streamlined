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
  
  def test_column_can_be_unassigned_with_model_that_has_no_validations
    model_class, column = flexmock, flexmock
    model_class.should_receive(:respond_to?).with('reflect_on_validations_for').and_return(true).once
    model_class.should_receive(:reflect_on_validations_for).with(column).and_return([])
    assert column_can_be_unassigned?(model_class, column)
  end
  
  def test_column_can_be_unassigned_with_model_that_has_validations
    model_class, column = flexmock, flexmock
    model_class.should_receive(:respond_to?).with('reflect_on_validations_for').and_return(true).once
    model_class.should_receive(:reflect_on_validations_for).with(column).and_return([flexmock(:macro => :validates_presence_of)])
    assert !column_can_be_unassigned?(model_class, column)
  end
end