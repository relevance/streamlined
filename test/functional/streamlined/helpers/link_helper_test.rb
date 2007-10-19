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

  def test_link_to_toggle_export
    html = @view.send("link_to_toggle_export")
    title = "Export People"
    look_for   = "a[href=#][onclick=\"Element.toggle('show_export'); return false;\"]"
    look_for_2 = "img[alt=#{title}][border=0][src=/images/streamlined/export_16.png][title=#{title}]"
    count = 1
    error_msg   = "Did not find #{look_for  } with count=#{count} in #{html}"
    error_msg_2 = "Did not find #{look_for_2} with count=#{count} in #{html}"
    assert_select root_node(html), look_for, {:count => count}, error_msg do
      assert_select look_for_2, {:count => count}, error_msg_2
    end  
  end

  def test_link_to_toggle_export_with_none
    @view.send(:model_ui).exporters :none                                                                                                                          
    assert_equal :none, @view.send(:model_ui).exporters
    html = @view.send("link_to_toggle_export")
    assert html.blank?, "html=#{html}.  It should be empty"
  end

  def test_link_to_submit_export
    html = @view.send("link_to_submit_export", {:action => :list})
    look_for = "a[href=#][onclick=\"Streamlined.Exporter.submit_export('/people/list'); return false;\"]"
    text = "Export"
    count = 1
    error_msg = "Did not find #{look_for} with count=#{count} and text=#{text} in #{html}"
    assert_select root_node(html), look_for, {:count => count, :text => text}, error_msg
  end

  def test_link_to_hide_export
    html = @view.send("link_to_hide_export")
    look_for = "a[href=#][onclick=\"Element.hide('show_export'); return false;\"]"
    text = "Cancel"
    count = 1
    error_msg = "Did not find #{look_for} with count=#{count} and text=#{text} in #{html}"
    assert_select root_node(html), look_for, {:count => count, :text => text}, error_msg
  end

  def test_show_columns_to_export_is_true_for_default
    formats = :csv, :json, :xml, :enhanced_xml_file, :xml_stylesheet, :enhanced_xml, :yaml
    @view.send(:model_ui).exporters formats
    assert_equal formats, @view.send(:model_ui).exporters
    assert_true @view.send("show_columns_to_export")
  end

  def test_show_columns_to_export_is_true
    formats = :enhanced_xml, :enhanced_xml_file, :xml_stylesheet
    formats.each do |format|
      @view.send(:model_ui).exporters format
      assert_equal format, @view.send(:model_ui).exporters
      assert_true @view.send("show_columns_to_export")
    end
  end

  def test_show_columns_to_export_is_false
    formats = :csv, :json, :xml, :yaml
    formats.each do |format|
      @view.send(:model_ui).exporters format
      assert_equal format, @view.send(:model_ui).exporters
      assert_false @view.send("show_columns_to_export")
    end
  end

end
