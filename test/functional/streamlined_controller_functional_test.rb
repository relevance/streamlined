require File.join(File.dirname(__FILE__), '../test_functional_helper')
require 'streamlined/controller'
require 'streamlined/ui'

# TODO: fold into the two meta-test classes
class StreamlinedControllerTest < Test::Unit::TestCase
  fixtures :people
  def setup
    @controller = PeopleController.new
    @controller.logger = RAILS_DEFAULT_LOGGER
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def generic_view(template)
    "../../../templates/generic_views/#{template}"
  end
  
  # TODO: make this true for every CRUD method
  # TODO: also assert that various handlers like onclick do not exist
  def assert_unobtrusive_javascript
    assert_select("script", :count=>0, :text=>/./)
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
    assert_select("\#model_list", true, "should have generic id names")
    assert_select("\#people_list", false, "should not have model-specific id names")
  end
  
  def test_list_with_filter
    get :list, :page_options=>{:filter=>"Justin"}
    assert_response :success
    assert_template generic_view("list")
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

  def test_show
    get :show, :id => 1
    assert_response :success
    assert_template generic_view("show")
    assert_not_nil assigns(:streamlined_item)
    assert assigns(:streamlined_item).valid?
    # TODO: refactor poke code so this becomes true
    # assert_unobtrusive_javascript
  end
  
  def test_new
    get :new
    assert_response :success
    assert_template generic_view("new")
    assert_not_nil assigns(:streamlined_item)
    assert_unobtrusive_javascript
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
  
  def test_edit
    get :edit, :id => 1
    assert_response :success
    assert_template generic_view("edit")
    assert_not_nil assigns(:streamlined_item)
    assert assigns(:streamlined_item).valid?
    assert_unobtrusive_javascript
  end
  
  def test_update
    assert_difference(Person, :count, 0) do
      post :update, :id=>'1', :person => {:first_name=>'Another', :last_name=>'Person'}
      assert_response :redirect
      assert_redirected_to :action => 'list'
    end
  end
  
  def test_update_xhr
    assert_difference(Person, :count, 0) do
      xhr :post, :update, :id=>'1', :person => {:first_name=>'Another', :last_name=>'Person'}
      assert_response :success
    end
  end
  
  def delete
    assert_difference(Person, :count, -1) do
      post :delete, :id=>'1'
      assert_response :redirect
      assert_redirected_to :action => 'list'
    end
  end
  
end
