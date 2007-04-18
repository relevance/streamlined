require File.join(File.dirname(__FILE__), '../../../test_functional_helper')
require 'streamlined/controller/enumeration_methods'

class Streamlined::Controller::EnumerationMethodsTest < Test::Unit::TestCase
  include Streamlined::Controller::EnumerationMethods
  attr_accessor :instance
  
  def setup
    @item = flexmock(:foo => 'selected_item')
    show_view = flexmock(:partial => 'show_partial')
    edit_view = flexmock(:partial => 'edit_partial')
    @rel_type = flexmock(:enumeration => 'all_items', :edit_view => edit_view, :show_view => show_view)
    
    (model = flexmock).should_receive(:find).with('123').and_return(@item).once
    (model_ui = flexmock).should_receive(:scalars).and_return(:foo => @rel_type).once
    
    flexmock(self, :model => model)
    flexmock(self, :model_ui => model_ui)
    flexmock(self, :params => { :id => '123', :enumeration => 'foo', :rel_name => 'foo' })
  end
  
  def test_edit_enumeration
    render_options = { :partial => 'edit_partial', :locals => { :item => @item }}
    flexmock(self).should_receive(:render).with(render_options).and_return('render_results').once

    assert_equal 'render_results', edit_enumeration
    assert_equal 'all_items', @all_items
    assert_equal 'selected_item', @selected_item
    assert_equal 'selected_item', instance.foo
    assert_equal 'foo', @enumeration_name
  end
  
  def test_show_enumeration
    render_options = { :partial => 'show_partial', :locals => { :item => @item, :relationship => @rel_type }}
    flexmock(self).should_receive(:render).with(render_options).and_return('render_results').once
    
    assert_equal 'render_results', show_enumeration
    assert_equal 'selected_item', instance.foo
  end
  
  def test_update_enumeration
    @item.should_receive(:update_attribute).with(:foo, nil).once
    flexmock(self).should_receive(:render).with(:nothing => true).and_return('render_results').once
    
    assert_equal 'render_results', update_enumeration
    assert_equal 'selected_item', instance.foo
  end
end