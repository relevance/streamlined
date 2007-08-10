module Relevance; end
module Relevance::Acceptance; end

# TODO Implement support for authorization-related testing (i.e., which roles should be
# allowed to perform certain tasks, etc.)   Example...
#
#   should_pass_for_roles :admin, :power_user
#   authorization_failure_should_be :redirect_to => :login
module Relevance::Acceptance::CrudTest
  module ClassMethods
    attr_accessor :model_name, :menu_navigation_to_list_view, :existing_record_link_text, :existing_record_data, 
                  :new_record_data, :new_record_header, :updates_to_existing_record_data, :existing_record_link_text_for_delete
    attr_with_default(:update_landing_page) {"show"}
    declarative_scalar :update_submit_button, :default=>"Save"
    declarative_scalar :data_should_fail_to_update
    
    def model_name_is(value)
      @model_name = value
    end

    def menu_navigation_to_list_view_is(*args)
      @menu_navigation_to_list_view = args
    end

    def existing_record_link_text_is(value)
      @existing_record_link_text = value
    end                             

    def existing_record_link_text_for_delete_is(value)
      @existing_record_link_text_for_delete = value
    end                             
    
    def existing_record_data_is(value)
      @existing_record_data = value
    end                          

    def new_record_data_is(value)
      @new_record_data = value
    end           
    
    def new_record_header_is(value)
      @new_record_header = value
    end
    
    def updates_to_existing_record_data_are(value)
      @updates_to_existing_record_data = value
    end                          
  end
  delegates(*(ClassMethods.instance_methods << {:to => "self.class"}))
  
  def self.included(includer)
    includer.module_eval {extend ClassMethods}
  end
  
  def navigate_to_list_view
    login!                 
    click_menu *menu_navigation_to_list_view
    wait
  end
  
  def navigate_to_show_view
    navigate_to_list_view
    click_link_and_wait existing_record_link_text
    user_should_see {
      title "show"
      header expected_show_header
    }
  end

  def navigate_to_edit_view
    navigate_to_list_view
    click_link_and_wait existing_record_link_text, :error_message=>"Unable to navigate through link text '#{existing_record_link_text}' to 'show' page for #{model_name}"
    click_link "Edit"
    sleep 1
    user_should_see {
      header expected_edit_header
    }
  end
  
  def test_list         
    navigate_to_list_view
    user_should_see {
      list_header
    }
  end
  
  def test_show
    navigate_to_list_view
    click_link_and_wait existing_record_link_text
    user_should_see {
      title "show"
      header expected_show_header
      show_table_with existing_record_data
    }
  end  
  
  def test_update
    navigate_to_edit_view
    user_should_see {
      header expected_edit_header
      edit_table_with existing_record_data
    }
    if data_should_fail_to_update
      enter_table_data data_should_fail_to_update
      click_submit update_submit_button
      user_should_see_errors
    end
    enter_table_data updates_to_existing_record_data
    click_submit update_submit_button
    user_should_not_see_errors 
    user_should_see {
      title update_landing_page
      header expected_show_header
      # TODO Add flash messages to Streamlined 'update' events
      # flash "#{model_name.to_s.titleize} was successfully updated."
      show_table_with updates_to_existing_record_data
    }
  end
       
  def test_create
    navigate_to_list_view
    click_image_and_wait "New #{model_name.to_s.titleize}"
    enter_table_data new_record_data
    click_submit "Create"
    user_should_not_see_errors
    user_should_see {
      header new_record_header
      # TODO Add flash messages to Streamlined 'create' events
      # flash "#{model_name.to_s.titleize} was successfully created."
      show_table_with new_record_data
    }
  end        
  
  def test_delete
    if existing_record_link_text_for_delete
      navigate_to_list_view
      page_contains existing_record_link_text_for_delete
      click_delete_in_list_view existing_record_link_text_for_delete
      js_confirmation "Are you sure?"
      # TODO Add flash messages to Streamlined 'delete' events
      # flash "#{model_name.to_s.humanize} was successfully deleted."
      user_should_see {
        title "list"
      }
      page_does_not_contain existing_record_link_text_for_delete
    else
      puts "#{self.class} - 'Delete' operations are not supported for this feature and therefore will not be tested."
    end
  end

  def list_header
    expected_header_text = model_name.to_s.pluralize.titleize  
    message = "Expected list header '#{expected_header_text}' to appear on the page, but it didn't."
    assert_equal expected_header_text, @selenium.get_text("xpath=//div[@class='streamlined_header']/h2"), message
  end

  def expected_show_header
    existing_record_link_text
  end

  def expected_edit_header
    "Editing #{existing_record_link_text}"
  end
end
