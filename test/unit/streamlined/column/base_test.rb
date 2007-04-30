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
    context = Streamlined::Context::ControllerContext.new
    addition = Addition.new(:test_addition)
    assert !addition.is_displayable_in_context?(context)
    
    association = Association.new(@ar_assoc, :inset_table, :list)
    assert association.is_displayable_in_context?(context)
    
    ar_column = flexmock(:name => 'column')
    ar = ActiveRecord.new(ar_column)
    assert ar.is_displayable_in_context?(context)
  end
  
end