require File.join(File.dirname(__FILE__), '../../../test_functional_helper')
require 'streamlined/controller/enumeration_methods'

class Streamlined::Controller::EnumerationMethodsTest < Test::Unit::TestCase
  include Streamlined::Controller::EnumerationMethods
  attr_accessor :instance
  
  def test_edit_enumeration
    setup_mocks(:enumeration => ['all', 'items'])
    should_render_with_partial('edit_partial')
    assert_equal 'render_results', edit_enumeration
    assert_equal [['all', 'all'], ['items', 'items']], @all_items
    assert_equal 'selected_item', @selected_item
    assert_equal 'selected_item', instance.foo
    assert_equal 'foo', @enumeration_name
  end
  
  def test_edit_enumeration_with_hash
    setup_mocks(:enumeration => { 'all' => 1, 'items' => 2 })
    should_render_with_partial('edit_partial')
    assert_equal 'render_results', edit_enumeration
    assert_equal [['items', 2], ['all', 1]], @all_items
  end
  
  def test_edit_enumeration_with_2d_array
    setup_mocks(:enumeration => [['all', 1], ['items', 2]])
    should_render_with_partial('edit_partial')
    assert_equal 'render_results', edit_enumeration
    assert_equal [['all', 1], ['items', 2]], @all_items
  end
  
  def test_show_enumeration
    setup_mocks(:enumeration => ['all', 'items'])
    should_render_with_partial('show_partial')
    assert_equal 'render_results', show_enumeration
    assert_equal 'selected_item', instance.foo
  end
  
  def test_update_enumeration
    setup_mocks(:enumeration => ['all', 'items'])
    should_update_and_render_nothing
    assert_equal 'render_results', update_enumeration
    assert_equal 'selected_item', instance.foo
  end

private
  def setup_mocks(options={})
    @item = flexmock(:foo => 'selected_item')
    show_view = flexmock(:partial => 'show_partial')
    edit_view = flexmock(:partial => 'edit_partial')
    @rel_type = flexmock(:enumeration => options[:enumeration], :edit_view => edit_view, :show_view => show_view)
    
    (model = flexmock).should_receive(:find).with('123').and_return(@item).once
    (model_ui = flexmock).should_receive(:scalars).and_return(:foo => @rel_type).once
    
    flexmock(self, :model => model)
    flexmock(self, :model_ui => model_ui)
    flexmock(self, :params => { :id => '123', :enumeration => 'foo', :rel_name => 'foo' })
  end
  
  def should_render_with_partial(partial)
    render_options = { :partial => partial, :locals => { :item => @item, :relationship => @rel_type }}
    flexmock(self).should_receive(:render).with(render_options).and_return('render_results').once
  end
  
  def should_update_and_render_nothing
    @item.should_receive(:update_attribute).with(:foo, nil).once
    flexmock(self).should_receive(:render).with(:nothing => true).and_return('render_results').once
  end
end