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
    assert_equal 'unassigned', @addition.unassigned_value
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
    assert !@addition.is_displayable_in_context?(flexmock(:crud_context => :new))
    assert @addition.is_displayable_in_context?(flexmock(:crud_context => :show))
    assert @addition.is_displayable_in_context?(flexmock(:crud_context => :list))
    assert !@addition.is_displayable_in_context?(flexmock(:crud_context => :edit))
    
    association = Association.new(@ar_assoc, nil, :inset_table, :list)
    association.create_only = true
    assert association.is_displayable_in_context?(flexmock(:crud_context => :new))
    assert association.is_displayable_in_context?(flexmock(:crud_context => :show))
    assert association.is_displayable_in_context?(flexmock(:crud_context => :list))
    assert !association.is_displayable_in_context?(flexmock(:crud_context => :edit))
    
    ar_column = flexmock(:name => 'column')
    ar = ActiveRecord.new(ar_column, nil)
    ar.create_only = true
    assert ar.is_displayable_in_context?(flexmock(:crud_context => :new))
    assert ar.is_displayable_in_context?(flexmock(:crud_context => :show))
    assert ar.is_displayable_in_context?(flexmock(:crud_context => :list))
    assert !ar.is_displayable_in_context?(flexmock(:crud_context => :edit))
  end
  
  def test_render_th
    association = Association.new(@ar_assoc, nil, :inset_table, :count)
    flexmock(association).should_receive(:sort_image => "<img src=\"up.gif\">")
    assert_equal expected_th, association.render_th(nil, nil)
  end
  
  def expected_th
    returning Builder::XmlMarkup.new do |xml|
      xml.th(:class => 'sortSelector', :scope => 'col', :col => 'name') do
        xml << "Some name<img src=\"up.gif\">"
      end
    end
  end
end