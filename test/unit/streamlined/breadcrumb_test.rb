require File.join(File.dirname(__FILE__), '../../test_helper')
require 'streamlined/breadcrumb'

class Streamlined::BreadcrumbTest < Test::Unit::TestCase
  include Streamlined::Breadcrumb
  
  def test_node_for_list_crud_context
    flexmock(self).should_receive(:link_to).with("Flex Mocks", :controller => "flex_mocks", :action => "list")
    instance = flexmock(:id => 123, :name => "foo")
    node_for(:list, instance).call
  end
  
  def test_node_for_show_crud_context
    flexmock(self).should_receive(:link_to).with("foo", :controller => "flex_mocks", :action => "show", :id => 123)
    instance = flexmock(:id => 123, :name => "foo")
    node_for(:show, instance).call
  end
  
  def test_node_for_bogus_crud_context
    assert_nil node_for(:bogus, flexmock)
  end
end