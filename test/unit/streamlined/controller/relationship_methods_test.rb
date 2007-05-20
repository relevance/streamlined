require File.join(File.dirname(__FILE__), '../../../test_helper')
require 'streamlined/controller/relationship_methods'

class StubClass
  def self.find(value)
    'new_item'
  end
end

class Streamlined::Controller::RelationshipMethodsTest < Test::Unit::TestCase
  include Streamlined::Controller::RelationshipMethods
  attr_accessor :params
  
  # begin stub methods
  def instance=(value)
  end
  
  def instance
    instance = flexmock
    instance.should_receive(:person_id=).with(nil)
    instance.should_receive(:person_id=).with('new_item')
    instance.should_receive(:save => true, :rel_name => [])
    instance
  end
  
  def render(options)
    assert options.is_a?(Hash)
    assert options[:nothing]
  end
  
  def model
    model = flexmock
    model.should_receive(:find).with('1').once
    model
  end
  # end stub methods
  
  def test_edit_relationship
    @params = { :id => '1', :relationship => 'person' }
    rel_type = flexmock(:edit_view => flexmock(:partial => 'partial'))
    flexmock(self) do |mock|
      mock.should_receive(:relationship_for_name).and_return(rel_type).once
      mock.should_receive(:set_items_and_all_items).with(rel_type).once
      expected_render_args = { :partial => 'partial', :locals => { :relationship => rel_type }}
      mock.should_receive(:render).with(expected_render_args).once
    end
    edit_relationship
  end
  
  def test_update_relationship
    @params = { :id => '1', :rel_name => 'rel_name', :klass => 'StubClass', :item => { '1' => 'on' }}
    build_update_relationship_mocks
    update_relationship
  end
  
  def test_update_relationship_without_item
    @params = { :id => '1', :rel_name => 'rel_name', :klass => 'StubClass' }
    build_update_relationship_mocks
    update_relationship
  end
  
  def test_update_n_to_one_with_nil_item
    @params = { :id => '1', :rel_name => 'person_id' }
    update_n_to_one
  end

  def test_update_n_to_one_with_item_and_klass
    @params = { :id => '1', :rel_name => 'person_id', :item => '1', :klass => 'StubClass' }
    update_n_to_one
  end
  
  def test_update_n_to_one_with_item_and_class_name
    @params = { :id => '1', :rel_name => 'person_id', :item => '1::StubClass' }
    update_n_to_one
  end
  
  def build_update_relationship_mocks
    rel_type = flexmock(:edit_view => flexmock(:partial => 'partial'))
    model_ui = flexmock(:relationships => { :rel_name => rel_type })
    flexmock(self) do |mock|
      mock.should_receive(:model_ui => model_ui).once
      mock.should_receive(:render).with(:nothing => true).once
    end
  end
end