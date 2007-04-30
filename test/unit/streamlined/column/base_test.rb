require File.join(File.dirname(__FILE__), '../../../test_helper')
require 'streamlined/column/association'
require 'streamlined/column/active_record'
require 'streamlined/column/addition'

class Streamlined::Column::BaseTest < Test::Unit::TestCase
  include Streamlined::Column
  include Streamlined::Context
  
  def setup
    @ar_assoc = flexmock
    @ar_assoc.should_expect do |o|
      o.name.returns('SomeName')
      o.class_name.returns('klass')
    end
  end
  
  def test_is_displayable_in_context
    view = flexmock(:crud_context => :edit)
    addition = Addition.new(:test_addition)
    assert !addition.is_displayable_in_context?(view)
    
    association = Association.new(@ar_assoc, :inset_table, :list)
    assert association.is_displayable_in_context?(view)
    
    ar_column = flexmock(:name => 'column')
    ar = ActiveRecord.new(ar_column)
    assert ar.is_displayable_in_context?(view)
  end
  
  def test_is_displayable_in_context_with_create_only_set_to_true
    addition = Addition.new(:test_addition)
    assert !addition.is_displayable_in_context?(flexmock(:crud_context => :new))
    assert addition.is_displayable_in_context?(flexmock(:crud_context => :show))
    assert addition.is_displayable_in_context?(flexmock(:crud_context => :list))
    assert !addition.is_displayable_in_context?(flexmock(:crud_context => :edit))
    
    association = Association.new(@ar_assoc, :inset_table, :list)
    association.create_only = true
    assert association.is_displayable_in_context?(flexmock(:crud_context => :new))
    assert association.is_displayable_in_context?(flexmock(:crud_context => :show))
    assert association.is_displayable_in_context?(flexmock(:crud_context => :list))
    assert !association.is_displayable_in_context?(flexmock(:crud_context => :edit))
    
    ar_column = flexmock(:name => 'column')
    ar = ActiveRecord.new(ar_column)
    ar.create_only = true
    assert ar.is_displayable_in_context?(flexmock(:crud_context => :new))
    assert ar.is_displayable_in_context?(flexmock(:crud_context => :show))
    assert ar.is_displayable_in_context?(flexmock(:crud_context => :list))
    assert !ar.is_displayable_in_context?(flexmock(:crud_context => :edit))
    
  end
  
end