require File.join(File.dirname(__FILE__), '../test_functional_helper')
require 'streamlined/controller'
require 'streamlined/ui'

class StreamlinedControllerTest < Test::Unit::TestCase
  fixtures :people
  
  def setup
    Streamlined::Registry.reset
    PeopleController.db_action_filters.clear
    @controller = PeopleController.new
    @controller.logger = RAILS_DEFAULT_LOGGER
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_delegated_methods_are_not_routable
    action_methods = PeopleController.action_methods.map(&:to_sym)
    assert_equal 0, (action_methods & Streamlined::Context::RequestContext::DELEGATES).size
    assert_equal 0, (action_methods & Streamlined::Context::ControllerContext::DELEGATES).size
  end

  def generic_view(template)
    "../../../templates/generic_views/#{template}"
  end
  
  def test_index
    get :index
    assert_response :success
    assert_template generic_view("list")
  end
  
  def test_list
    get :list
    assert_response :success
    assert_template generic_view("list")
    assert_kind_of(ActionController::Pagination::Paginator, assigns(:streamlined_item_pages))
    assert_select("\#model_list", true, "should have generic id names for Ajax.Updater to replace")
    assert_select("\#people_list", false, "should not have model-specific id names")
    assert_select 'table#sl_list_people', true, 'table should have generic id for acceptance testing'
  end
  
  def test_list_with_non_ar_column
    get :list, :page_options=>{:sort_column=>"full_name", :sort_order=>"DESC"}
    assert_response :success
    assert_template generic_view("list")
    assert_equal [people(:stu), people(:justin)], assigns(:streamlined_items)
  end
  
  def test_list_with_filter
    get :list, :page_options=>{:filter=>"Justin"}
    assert_response :success
    assert_template generic_view("list")
  end
  
  def test_list_with_no_pagination
    class <<@controller
      def pagination; false; end
    end
    get :list
    assert_response :success
    assert_template generic_view("list")
    assert_equal([], assigns(:streamlined_item_pages))
  end
              
  def test_empty_list   
    Person.delete_all
    get :list
    assert_response :success                          
    assert_select "tr[class=odd]", 1, "Should have exactly one tr with odd style only--no row/instance specific styles" do
      assert_select "div[class=sl_list_empty_message]"
    end
  end
  
  # TODO: set Content-Disposition? optional?
  # @headers["Content-Disposition"] = "attachment; filename=\"#{Inflector.tableize(model_name)}_#{Time.now.strftime('%Y%m%d')}.csv\""
  def test_list_xml
    @request.env["HTTP_ACCEPT"] = "application/xml"
    get :list
    assert_response :success
    assert_template nil
    assert_equal "application/xml", @response.content_type
    assert_select("people person", {:count=>2})
  end

  def test_list_csv
    @request.env["HTTP_ACCEPT"] = "text/csv"
    get :list
    assert_response :success
    assert_template nil
    assert_equal "text/csv", @response.content_type
    assert_equal(<<-END, @response.body)
id,first_name,last_name
1,Justin,Gehtland
2,Stu,Halloway
END
  end       

  def test_list_json
    @request.env["HTTP_ACCEPT"] = "application/json"
    get :list
    assert_response :success
    assert_template nil
    assert_equal "application/json", @response.content_type   
    expected_json =<<-END
    [{attributes: {id: "1", first_name: "Justin", last_name: "Gehtland"}}, {attributes: {id: "2", first_name: "Stu", last_name: "Halloway"}}]
END
    expected_json = expected_json.strip
    assert_equal(expected_json, @response.body)
  end       

  def test_popup
    get :popup, :id => 1
    assert_equal people(:justin), assigns(:person)
    assert_template generic_view("_popup") 
  end
  
  def test_show
    get :show, :id => 1
    assert_response :success
    assert_template generic_view("show")
    assert_not_nil assigns(:streamlined_item)
    assert assigns(:streamlined_item).valid?
    assert_select '#sl_field_person_first_name' do
      assert_select 'td.sl_show_label', 'First Name:'
      assert_select 'td.sl_show_value', 'Justin'
    end
    # TODO: refactor poke code so this becomes true
    # assert_unobtrusive_javascript
  end
  
  def test_edit
    get :edit, :id => 1
    assert_response :success
    assert_template generic_view("edit")
    assert_not_nil assigns(:streamlined_item)
    assert assigns(:streamlined_item).valid?
    assert_select '#sl_field_person_first_name' do
      assert_select 'td.sl_edit_label label', 'First Name'
      assert_select 'td.sl_edit_value input', ''  # test value='Justin'?
    end
  end

  def test_new
    get :new
    assert_response :success
    assert_template generic_view("new")
    assert_not_nil assigns(:streamlined_item)
    assert assigns(:streamlined_item).valid?
    assert_select '#sl_field_person_first_name' do
      assert_select 'td.sl_edit_label label', 'First Name'
      assert_select 'td.sl_edit_value input', ''
    end
  end
  
  def test_create_xhr
    assert_difference(Person, :count) do
      xhr :post, :create, :person => {:first_name=>'Another', :last_name=>'Person'}
      assert_response :success
    end
  end

  def test_create
    assert_difference(Person, :count) do
      post :create, :person => {:first_name=>'Another', :last_name=>'Person'}
      assert_response :redirect
      assert_redirected_to :action => 'list'
    end
  end
  
  def test_create_with_db_action_filter_returning_true
    instance = setup_db_action_filters_test(true, :save)
    @controller.class.db_action_filter :create, Proc.new { instance.foo }
    post :create
    assert_response :redirect
  end

  def test_create_with_db_action_filter_returning_false
    instance = setup_db_action_filters_test(false, :save)
    @controller.class.db_action_filter :create, Proc.new { instance.foo }
    post :create
    assert_response :success
  end

  def test_update_with_db_action_filter_returning_true
    instance = setup_db_action_filters_test(true, :update_attributes)
    @controller.class.db_action_filter :update, Proc.new { instance.foo }
    post :update, :id => 1 
    assert_response :redirect
  end

  def test_update_with_db_action_filter_returning_false
    instance = setup_db_action_filters_test(false, :update_attributes)
    @controller.class.db_action_filter :update, Proc.new { instance.foo }
    post :update, :id => 1
    assert_response :success
  end
  
  def test_quick_add_uses_correct_form_field_labels
    xhr :get, :quick_add, :select_id => "foo", :model_class_name => "Poet"
    assert_response :success
    assert_template "quick_add"
    assert_match %r{<label for="poet_first_name">First Name</label>}, @response.body
    assert_match %r{<label for="poet_last_name">Last Name</label>}, @response.body
  end

  def test_instance_is_accessible
    # This would fail if it was private
    @controller.access_instance
    
    get :show_special, :id => 1
    assert_response :success
    assert_equal people(:justin), assigns(:person)    
    assert_equal people(:justin), assigns(:streamlined_item)
  end
  
  def test_instance_is_not_an_action
    get :instance
    flunk "Should have thrown an UnknownAction exception"
  rescue ActionController::UnknownAction => e
    assert_equal "No action responded to instance", e.message
  end
  
  private

  def setup_db_action_filters_test(filter_return_value, default_method)
    instance = flexmock(@controller.send(:instance))
    instance.should_receive(:foo).and_return(filter_return_value).once
    instance.should_receive(default_method).never
    instance
  end
    
end
