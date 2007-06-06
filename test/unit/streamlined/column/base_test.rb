require File.join(File.dirname(__FILE__), '../../../test_helper')
require 'streamlined/column/association'
require 'streamlined/column/active_record'
require 'streamlined/column/addition'

class Streamlined::Column::BaseTest < Test::Unit::TestCase
  include Streamlined::Column
  include Streamlined::Context
  
  def setup
    @ar_assoc = flexmock(:name => 'some_name', :class_name => 'SomeName')
    @addition = Addition.new(:test_addition, nil)
  end
  
  def test_belongs_to
    assert !@addition.belongs_to?
  end
  
  def test_unassigned_value_receives_default
    assert_equal 'Unassigned', @addition.unassigned_value
  end
  
  def test_render_content
    (item = flexmock).should_receive(:send).with('test_addition').and_return('<b>content</b>').once
    assert_equal '&lt;b&gt;content&lt;/b&gt;', @addition.render_content(nil, item)
  end
  
  def test_render_content_with_allow_html_set_to_true
    @addition.allow_html = true
    (item = flexmock).should_receive(:send).with('test_addition').and_return('<b>content</b>').once
    assert_equal '<b>content</b>', @addition.render_content(nil, item)
  end
  
  def test_is_displayable_in_context
    view = flexmock(:crud_context => :edit)
    assert !@addition.is_displayable_in_context?(view)
    
    association = Association.new(@ar_assoc, nil, :inset_table, :list)
    assert association.is_displayable_in_context?(view)
    
    ar_column = flexmock(:name => 'column')
    ar = ActiveRecord.new(ar_column, nil)
    assert ar.is_displayable_in_context?(view)
  end
  
  def test_is_displayable_in_context_with_create_only_set_to_true
    @addition.create_only = true
    assert_displayable_in_contexts @addition, :new => false, :show => true, :list => true, :edit => false
    
    association = Association.new(@ar_assoc, nil, :inset_table, :list)
    association.create_only = true
    assert_displayable_in_contexts association, :new => true, :show => true, :list => true, :edit => false
    
    ar_column = flexmock(:name => 'column')
    ar = ActiveRecord.new(ar_column, nil)
    ar.create_only = true
    assert_displayable_in_contexts ar, :new => true, :show => true, :list => true, :edit => false
  end
  
  def test_is_displayable_in_context_with_update_only_set_to_true
    @addition.update_only = true
    assert_displayable_in_contexts @addition, :new => false, :show => true, :list => true, :edit => false
    
    association = Association.new(@ar_assoc, nil, :inset_table, :list)
    association.update_only = true
    assert_displayable_in_contexts association, :new => false, :show => true, :list => true, :edit => true
    
    ar_column = flexmock(:name => 'column')
    ar = ActiveRecord.new(ar_column, nil)
    ar.update_only = true
    assert_displayable_in_contexts ar, :new => false, :show => true, :list => true, :edit => true
  end
  
  def test_render_th
    association = Association.new(@ar_assoc, nil, :inset_table, :count)
    flexmock(association).should_receive(:sort_image => "<img src=\"up.gif\">")
    assert_equal expected_th, association.render_th(nil, nil)
  end
  
  def test_wrapper
    association = Association.new(@ar_assoc, nil, :inset_table, :count)
    assert_equal 'content', association.wrap('content')
    association.wrapper = :object_that_does_not_respond_to_call
    assert_equal 'content', association.wrap('content')
    association.wrapper = Proc.new { |c| "<<<#{c}>>>" }
    assert_equal '<<<content>>>', association.wrap('content')
  end
  
private
  def expected_th
    returning Builder::XmlMarkup.new do |xml|
      xml.th(:class => 'sortSelector', :scope => 'col', :col => 'name') do
        xml << "Some name<img src=\"up.gif\">"
      end
    end
  end
  
  def assert_displayable_in_contexts(column, expectations={})
    assert_equal expectations[:new],  column.is_displayable_in_context?(flexmock(:crud_context => :new))
    assert_equal expectations[:show], column.is_displayable_in_context?(flexmock(:crud_context => :show))
    assert_equal expectations[:list], column.is_displayable_in_context?(flexmock(:crud_context => :list))
    assert_equal expectations[:edit], column.is_displayable_in_context?(flexmock(:crud_context => :edit))
  end
end