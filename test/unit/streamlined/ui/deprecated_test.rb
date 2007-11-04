require File.join(File.dirname(__FILE__), '../../../test_helper')
require 'streamlined/ui/deprecated'

class Streamlined::DeprecatedTest < Test::Unit::TestCase
  include Streamlined::DeprecatedUIClassMethods
  
  def test_deprecated_class_methods
    methods = deprecated_class_methods
    assert methods.is_a?(Set)
    assert methods.size > 5
  end
  
  def test_deprecated_class_methods_dont_get_reassigned_if_already_set
    @deprecated_class_methods = :foo
    assert_equal :foo, deprecated_class_methods
  end
end