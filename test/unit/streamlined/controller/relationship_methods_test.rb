require File.join(File.dirname(__FILE__), '../../../test_helper')
require 'streamlined/controller/relationship_methods'

class StubClass
  def self.find(value)
    'new_item'
  end
end

class Streamlined::Controller::RelationshipMethodsTest < Test::Unit::TestCase
  def setup
    @inst = Object.new
    class <<@inst
      include Streamlined::Controller::RelationshipMethods
      attr_accessor :params, :crud_context
      def instance=(value); end
    end
  end
  
  def test_show_relationship
    @inst.params = { :id => '1', :relationship => 'person' }
    flexmock(@inst) do |mock|
      mock.should_receive(:model).and_return(flexmock(:find => :item))
      mock.should_receive(:context_column).with('person').and_return(:relationship).once
      mock.should_receive(:render_show_view_partial).with(:relationship, :item).once
    end
    @inst.show_relationship
  end
  
  def test_render_show_view_partial
    show_view = flexmock('show_view', :partial => :partial)
    relationship = flexmock('relationship', :show_view => show_view)
    flexmock(@inst) do |mock|
      mock.should_receive(:render).with(:partial => :partial, :locals => {:item => :item, :relationship => relationship, :streamlined_def => show_view}).once
    end
    @inst.render_show_view_partial(relationship, :item)
  end
  
  def test_edit_relationship
    @inst.params = { :id => '1', :relationship => 'person' }
    rel_type = flexmock(:edit_view => flexmock(:partial => 'partial'))
    flexmock(@inst) do |mock|
      mock.should_receive(:model).and_return(flexmock('model', :find => nil))
      mock.should_receive(:context_column).and_return(rel_type).once
      mock.should_receive(:set_items_and_all_items).with(rel_type).once
      expected_render_args = { :partial => 'partial', :locals => { :relationship => rel_type }}
      mock.should_receive(:render).with(expected_render_args).once
    end
    @inst.edit_relationship
  end
    
  def test_update_relationship
    @inst.params = { :id => '1', :rel_name => 'rel_name', :klass => 'StubClass', :item => { '1' => 'on' }}
    build_update_relationship_mocks
    @inst.update_relationship
  end
  
  def test_update_relationship_without_item
    @inst.params = { :id => '1', :rel_name => 'rel_name', :klass => 'StubClass' }
    build_update_relationship_mocks
    @inst.update_relationship
  end
  
  def test_update_n_to_one_with_nil_item
    @inst.params = { :id => '1', :rel_name => 'rel_name' }
    build_n_to_one_mocks
    @inst.update_n_to_one
  end
  
  def test_update_n_to_one_with_item_and_klass
    @inst.params = { :id => '1', :rel_name => 'rel_name', :item => '1', :klass => 'StubClass' }
    build_n_to_one_mocks
    @inst.update_n_to_one
  end
  
  def test_update_n_to_one_with_item_and_class_name
    @inst.
    params = { :id => '1', :rel_name => 'rel_name', :item => '1::StubClass' }
    build_n_to_one_mocks
    @inst.update_n_to_one
  end
  
  
  def build_n_to_one_mocks
    rel_type = flexmock('edit_view', :edit_view => flexmock(:partial => 'partial'))
    model_ui = flexmock('relationships', :relationships => { :rel_name => rel_type })
    current_item = flexmock('instance', :save => true, :rel_name= => nil, :rel_name => flexmock('rel_name', :clear => nil, :push => nil, :replace => nil))
    flexmock(@inst) do |mock|
      mock.should_receive(:instance).and_return(current_item)
      mock.should_receive(:model).and_return(flexmock('model', :find => current_item))
      mock.should_receive(:render).with(:nothing => true).once
    end
  end
    
  def build_update_relationship_mocks
    rel_type = flexmock('edit_view', :edit_view => flexmock(:partial => 'partial'))
    model_ui = flexmock('relationships', :relationships => { :rel_name => rel_type })
    current_item = flexmock('instance', :save => true, :rel_name => flexmock('rel_name', :clear => nil, :push => nil, :replace => nil))
    flexmock(@inst) do |mock|
      mock.should_receive(:context_column).and_return(rel_type)
      mock.should_receive(:instance).and_return(current_item)
      mock.should_receive(:model).and_return(flexmock('model', :find => current_item))
      mock.should_receive(:render).with(:nothing => true).once
    end
  end
end