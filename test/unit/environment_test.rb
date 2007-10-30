require File.join(File.dirname(__FILE__), '/../test_helper')

class StreamlinedEnvironmentTest < Test::Unit::TestCase
  
  def test_pagination_is_available
    assert defined?(ActionController::Pagination) 
  end
  
  def test_should_require_pagination_plugin
    ignore_any_dynamic_constants_set
    Streamlined::Environment.expects(:require_streamlined_plugin).with(:classic_pagination)
    Streamlined::Environment.init_environment
  end

  def test_should_init_streamlined_paths
    ignore_any_dynamic_constants_set
    Streamlined::Environment.expects(:init_streamlined_paths)
    Streamlined::Environment.init_environment
  end
  
  def test_should_use_absolute_path_for_streamlined_root_if_the_path_exists_and_is_a_directory
    path_in_actual_rails_app = File.expand_path(File.join(RAILS_ROOT, "vendor/plugins/streamlined"))
    Pathname.any_instance.expects(:directory?).returns(true)
    Streamlined::Environment.find_streamlined_root.should == path_in_actual_rails_app
  end
  
  def test_should_fallback_to_two_directories_up_for_streamlined_root_if_necessary
    path = File.expand_path(File.join(File.dirname(__FILE__), "../../"))
    Pathname.any_instance.expects(:directory?).returns(false)
    Streamlined::Environment.find_streamlined_root.should == path
  end
  
  def test_should_use_relative_path_for_streamlined_template_root_to_stay_backwards_compatible
    Pathname.new(Streamlined::Environment.find_template_root).should.be.relative
  end
  
  # avoid errors by not actually setting constants in the test
  def ignore_any_dynamic_constants_set
    Object.stubs(:const_set)
  end
end