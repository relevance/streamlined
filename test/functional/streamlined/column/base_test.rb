require File.join(File.dirname(__FILE__), '../../../test_functional_helper')
require 'streamlined/helpers/link_helper'

class Streamlined::Column::BaseTest < Test::Unit::TestCase
  fixtures :people
  
  # s/b setup but for some reason rcov doesn't call setup (this class only)
  def ui
    unless @ui
      stock_controller_and_view
      @ui = Streamlined::UI.new(Person)
    end
    @ui
  end
  
  def test_render_straight_td
    assert_equal "Justin", ui.column(:first_name).render_td(@view,people(:justin))
  end

  def test_render_link_td
    ui.user_columns :first_name, {:link_to=>{:action=>"foo"}}
    assert_equal '<a href="/people/foo/1">Justin</a>', ui.column(:first_name).render_td(@view,people(:justin))
    assert_equal '<a href="/people/foo/2">Stu</a>', ui.column(:first_name).render_td(@view,people(:stu))
  end

  def test_render_link_to_in_list_td
    ui.user_columns :first_name, {:link_to_in_list=>{:action=>"foo"}}
    assert_equal '<a href="/people/foo/1">Justin</a>', ui.column(:first_name).render_td(@view,people(:justin))
    assert_equal '<a href="/people/foo/2">Stu</a>', ui.column(:first_name).render_td(@view,people(:stu))
    

    view = flexmock(:crud_context => :show)
    assert_equal 'Stu', ui.column(:first_name).render_td(view,people(:stu))
    
  end
  
  def test_render_popup_td
    ui.user_columns :first_name, {:popup=>{:action=>"foo"}}
    assert_equal '<span class="sl-popup"><a href="/people/foo/1" style="display:none;"></a>Justin</span>', ui.column(:first_name).render_td(@view,people(:justin))
  end
  
  def test_sort_image_up
    options = Streamlined::Context::RequestContext.new(:sort_column=>"first_name")
    assert_equal "<img alt=\"Arrow-up_16\" border=\"0\" height=\"10px\" src=\"/images/streamlined/arrow-up_16.png\" />", 
                 ui.column(:first_name).sort_image(options,@view)
  end

  def test_sort_image_down
    options = Streamlined::Context::RequestContext.new(:sort_column=>"first_name", :sort_order=>"DESC")
    assert_equal "<img alt=\"Arrow-down_16\" border=\"0\" height=\"10px\" src=\"/images/streamlined/arrow-down_16.png\" />", 
                 ui.column(:first_name).sort_image(options,@view)
  end

  def test_sort_image_none
    options = Streamlined::Context::RequestContext.new
    assert_equal '', ui.column(:first_name).sort_image(options,nil)
  end
  
  def test_div_wrapper
    result = ui.column(:first_name).div_wrapper(123) { 'contents' }
    assert_equal "<div id=\"123\">contents</div>", result
  end
  
  def test_render_tr_edit
    # simulate controller, view, context, and ivar naming convention...
    ui
    @controller.send :crud_context=, :edit
    @view.instance_variable_set(:@person, people(:stu))
    # and then test what we get
    root = root_node(ui.column(:first_name).render_tr_edit(@view, people(:stu)))
    assert_select root, "tr[id=sl_field_person_first_name]" do
      assert_select "td[class=sl_edit_label]" do
        assert_select "label[for=person_first_name]", "First Name"
      end
      assert_select "td[class=sl_edit_value]" do
        assert_select "input[id=person_first_name][size=30][value=Stu][type=text]" do
          assert_select "[name=?]", "person[first_name]"
        end
      end
    end
  end
end