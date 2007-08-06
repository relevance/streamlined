require File.join(File.dirname(__FILE__), '../../../test_functional_helper')
require 'streamlined/helpers/link_helper'

class Streamlined::Helpers::LinkHelperTest < Test::Unit::TestCase
  fixtures :people, :phone_numbers
  
  def setup
    stock_controller_and_view
  end
  
  def test_guess_show_link_for
    assert_equal "(multiple)", @view.guess_show_link_for([])
    assert_equal "(unassigned)", @view.guess_show_link_for(nil)
    assert_equal "(unknown)", @view.guess_show_link_for(1)
    assert_equal "<a href=\"/people/show/1\">1</a>", @view.guess_show_link_for(people(:justin))
    assert_equal "<a href=\"/phone_numbers/show/1\">1</a>", @view.guess_show_link_for(phone_numbers(:number1))
  end
  
  # TODO: make link JavaScript unobtrusive!
  def test_link_to_new_model
    assert_equal "<a href=\"/people/new\"><img alt=\"New Person\" border=\"0\" src=\"/images/streamlined/add_16.png\" title=\"New Person\" /></a>", @view.link_to_new_model
  end
  
  def test_link_to_new_model_when_quick_new_button_is_false
    @view.send(:model_ui).quick_new_button false
    assert_nil @view.link_to_new_model
  end

  def test_link_to_edit_model
    assert_equal "<a href=\"/people/edit/1\"><img alt=\"Edit Person\" border=\"0\" src=\"/images/streamlined/edit_16.png\" title=\"Edit Person\" /></a>", @view.link_to_edit_model(people(:justin))
  end
  
  def test_wrap_with_link
    assert_equal '<a href="/people/show/1">foo</a>', 
                 @view.wrap_with_link(:action=>"show", :id=>@item.id) {"foo"}
  end
  
  def test_link_toggle_element
    assert_equal '<a href="#some_elem" class="sl_toggler">click me</a>',
                 @view.link_to_toggler('click me', 'some_elem')
  end

  def test_all_export_links_are_present_by_default
    [:csv, :xml, :json].each {|format| assert_export_link(format)}                                                                                                 
  end                                                                                                                                                              
                                                                                                                                                                   
  def test_declarative_exporters_none                                                                                                                              
    @view.send(:model_ui).exporters :none                                                                                                                          
    [:csv, :xml, :json].each {|format| assert_export_link(format, false)}                                                                                          
  end                                                                                                                                                              
                                                                                                                                                                   
  def test_declarative_exporters_all                                                                                                                               
    @view.send(:model_ui).exporters :csv, :json, :xml                                                                                                              
    [:csv, :xml, :json].each {|format| assert_export_link(format)}                                                                                                 
  end                                                                                                                                                              

  def test_declarative_exporters_one
    @view.send(:model_ui).exporters :yaml
    assert_export_link(:yaml)
    [:xml, :json, :csv].each {|format| assert_export_link(format, false)}
  end

  def test_declarative_exporters_several
    @view.send(:model_ui).exporters :csv, :xml
    [:csv, :xml].each {|format| assert_export_link(format)}
    assert_export_link(:json, false)
  end

private
  def assert_export_link(format, should_be_present = true)
    image_type = {:csv => :save, :xml => :export, :json => :export, :yaml => :export}[format]
    html = @view.send("link_to_#{format}_export")
    title = "Export #{format.to_s.upcase}"
    assert_select root_node(html), "a[href=#][onclick=\"Streamlined.Exporter.export_to('/people?format=#{format}'); return false;\"]", :count => should_be_present ? 1 : 0 do
      assert_select "img[alt=#{title}][border=0][src=/images/streamlined/#{image_type}_16.png][title=#{title}]"
    end  
  end 
end
