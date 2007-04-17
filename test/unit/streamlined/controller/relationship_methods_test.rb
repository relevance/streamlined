require File.join(File.dirname(__FILE__), '../../../test_helper')
require 'streamlined/controller/relationship_methods'

class StubClass
  def self.find(value)
    'new_item'
  end
end

class Streamlined::Controller::RelationshipMethodsTest < Test::Unit::TestCase
  include Streamlined::Controller::RelationshipMethods
  include FlexMock::TestCase
  attr_accessor :params
  
  # begin stub methods
  def instance=(value)
  end
  
  def instance
    instance = flexmock
    instance.should_receive(:person_id=).with(nil)
    instance.should_receive(:person_id=).with('new_item')
    instance.should_receive(:save).and_return(true)
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
end