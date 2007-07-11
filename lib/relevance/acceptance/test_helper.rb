module Relevance; end
module Relevance::Acceptance; end

module Relevance::Acceptance::TestHelper             
  delegates :is_element_present, :to=>:selenium
  attr_accessor :selenium
  attr_with_default(:selenium_wait) {10000}                                       
  
  def click(options)
    case options
    when String
      @selenium.click options
    when Hash
      @selenium.click "xpath=//*[text()='#{options[:inside]}']//input[@value='#{options[:button]}']"
    else
      raise ArgumentError, options.inspect
    end
  end
  
  # Apparently, Selenium doesn't support querying the checked/unchecked status of a check box
  # right now. This means there isn't a way to set a check box to true/false... we can only
  # assume an initial state and click to change that state.
  # See: http://ingeniweb.sourceforge.net/Products/PloneSelenium/doc/FAQ
  def click_check_box(id)
    @selenium.click "id=#{id}"
  end
  
  def click_menu(menu_id, *rest)  
    @selenium.click menu_xpath(menu_id, *rest)
    wait
    yield if block_given?
  end
    
  def wait
    @selenium.wait_for_page_to_load selenium_wait
  end
  
  def click_and_wait(locator)
    @selenium.click locator
    wait
  end                       
  
  def click_link(names)
    names.each do |name|
      @selenium.click "link=#{name}"
    end
  end

  def open(url)
    @selenium.open url
    wait
  end
  
  # TODO: assert some real tab semantic here (CSS style associated w/tabs?)
  alias :click_tab :click_link
  
  def with_optional_error_message(err, msg = nil, &blk)
    if msg
      assert_nothing_raised(SeleniumCommandError, msg, &blk)
    else
      blk.call
    end
  end
  
  def click_link_and_wait(*names)
    options = (Hash === names.last) ? names.pop : {}
    names.each do |name|
      with_optional_error_message(SeleniumCommandError, options[:error_message]) do
        @selenium.click "link=#{name}"
        wait
      end
    end
  end       

  def click_image(*alts)
    alts.each do |alt|
      click "xpath=//img[@alt='#{alt}']"
    end
  end

  def click_image_and_wait(*alts)
    alts.each do |alt|
      click_and_wait "xpath=//img[@alt='#{alt}']"
    end
  end

  def click_edit_in_list_view(model_name, row_text)
    click_and_wait "//td[text()='#{row_text}']/../td//img[@alt='Edit #{model_name.to_s.humanize}']"
  end
              
  def click_delete_in_list_view(row_text)
    click_and_wait "//td/a[text()='#{row_text}']/../../td//img[@alt='Destroy']"
  end             
                                      
  # Clicks the delete icon for a child item in the edit view of a 1:n relationship.
  # For example, if the edit view for poets happened to contain a list of poems, this
  # method would click the delete icon for the specified poem.
  def click_delete_in_association_list(row_text)
    click "//td[text()='#{row_text}']/../td//img[@alt='Destroy']"
  end             
  
  def click_button(value)
    @selenium.click "xpath=//input[@type='button'][@value='#{value}']"
  end
  
  def click_submit(value=nil)
    xpath = "xpath=//input[@type='submit']"
    xpath << "[@value='#{value}']" unless value.blank? 
    @selenium.click xpath
  end
  
  def title(expected_title)
    assert_equal expected_title, @selenium.get_title, "Expected title '#{expected_title}' " <<
      " to appear on the page, but it didn't."
  end
  
  def header(expected_header)
    message = "Expected header '#{expected_header}' to appear on the page, but it didn't."
    assert_equal expected_header, @selenium.get_text("xpath=//div[@class='streamlined_header']/h2"), message
  end                                        
  
  def page_contains(expected_text)
    message = "Expected '#{expected_text}' to appear somewhere on the page, but it didn't."
    assert @selenium.is_text_present(expected_text), message
  end

  def page_does_not_contain(expected_text)
    message = "Expected '#{expected_text}' to *not* appear anywhere on the page, but it did."
    assert !@selenium.is_text_present(expected_text), message
  end
  
  def table_row(row_id, *expected_table_row)
    expected_table_row.each_with_index do |value, index|
      assert_equal value, @selenium.get_text("xpath=//tr[@id='#{row_id}']/td[#{index + 1}]")   
    end
  end
                               
  def element_present(locator, message=nil)
    assert is_element_present(locator), message || "Could not find expected HTML: #{locator}"
  end

  def element_not_present(locator, message=nil)
    if is_element_present(locator)
      fail message || "Found unexpected HTML: #{locator}"
    end
  end
  
  def submit_button_present(value)
    element_present "//input[@type='submit'][@value='#{value}']"
  end
  
  def flash(expected_msg)
    locator = "id=flash"
    message = "Expected flash '#{expected_msg}' to appear on the page, but it didn't."
    assert is_element_present(locator), message
    assert_equal expected_msg, @selenium.get_text(locator), message
  end
  
  def js_confirmation(expected_msg)
    assert_equal expected_msg, @selenium.get_confirmation
  end

  def select_option(select_id, option_locator)
    @selenium.select select_id, option_locator
  end
  
  def option_selected(select_id, option_value)
    xpath = "xpath=//select[@id='#{select_id}']//option[@value='#{option_value}']/@selected"
    assert_equal "selected", @selenium.get_attribute(xpath)
  end
    
  def type(fields_and_values)
    fields_and_values.each do |field, value|
      @selenium.type field, value
    end
  end   

  def field_present(label, value)
    assert_equal value, @selenium.get_text("//td[text()='#{label}']/following-sibling::td").strip
      "Expected to find field with label [#{label}] and value [#{value}], but no such field was present."
  end
  
  def input_field_present(label, value, input=:text_field)  
    case input
    when :text_field
      locator = "//td/label[text()='#{label}']/../following-sibling::td//input"
      locator << "[@value='#{value}']" unless value.blank?
    when :select
      locator = "//td/label[text()='#{label}']/../following-sibling::td/select/option[@selected='selected' and text()='#{value}']"
    when :text_area
      locator = "//td/label[text()='#{label}']/../following-sibling::td/textarea"
      locator << "[@value='#{value}']" unless value.blank?
    when :date
      locator = "//td/label[text()='#{label}']/../following-sibling::td/div[@class='calendar_wrapper']/input"
      locator << "[@value='#{value}']" unless value.blank?
    when :checkbox
      locator = "//td/label[text()='#{label}']/../following-sibling::td/input"
      checked = @selenium.is_checked(locator)
      expected_checked = value == "true"
      return checked == expected_checked
    else
      raise ArgumentError, input
    end
    assert @selenium.is_element_present(locator), "Expected to find [#{input}] field " <<
      "with label [#{label}] and value [#{value}], but no such field was present."
  end
  
  def check_box_present(id)
    assert @selenium.is_element_present("id=#{id}"),
      "Expected to find check box with ID of '#{id}', but none was present."
  end
  
  def enter_data(label, value, input=:text_field)  
    case input
    when :text_field
      @selenium.type "//td/label[text()='#{label}']/../following-sibling::td//input", value
    when :select
      @selenium.select "//td/label[text()='#{label}']/../following-sibling::td//select", value
    when :text_area
      @selenium.type "//td/label[text()='#{label}']/../following-sibling::td//textarea", value
    when :date
      @selenium.type "//td/label[text()='#{label}']/../following-sibling::td/div/input", value
    when :checkbox
      if value == "true"
        @selenium.check "//td/label[text()='#{label}']/../following-sibling::td//input"
      else
        @selenium.uncheck "//td/label[text()='#{label}']/../following-sibling::td//input"        
      end
    else
      raise ArgumentError, input
    end
  end

  def user_should_see_errors
    element_present("errorExplanation", "Expected a validation error message")
  end

  # TODO: could write a "user_does_not_see" that takes a block, but all
  #       the lookup methods would need to operate reversibly. Too clever.
  def user_should_not_see_errors
    # Test for both the error box and the individual error styling
    # Good error messages would be nice too
    element_not_present("errorExplanation", "Unexpected validation error message in UI")
    
    # css does not work, use xpath
    # element_not_present("css=div.fieldWithErrors") does not work
    element_not_present("xpath=//div[contains(./@class,'fieldWithErrors')]")
  end
    
  def crud_table_of(model_type)
    element_present "sl_list_#{model_type}"
  end
  
  def create_form_for(model_type)
    element_present "xpath=//form[@action='/#{model_type}/create']"
  end
  
  def select_list_for(base_type, sub_type)
    element_present "xpath=//select[@id='#{base_type.to_s.singularize}_#{sub_type.to_s.singularize}_id']"
  end
  
  def quick_add_form_for(base_type, qa_type)
    element_present "xpath=//form[@action='/#{base_type}/save_quick_add']"
    element_present "xpath=//input[@id='model_class_name'][@value='#{qa_type.to_s.capitalize}']"
  end

  def quick_edit_form_for(base_type, qe_type, id)
    element_present "xpath=//form[@action='/#{base_type}/update_#{qe_type}/#{id}']"
  end
  
  # Validates that a given Quick Add field is marked as required
  def required_quick_add_field(base_type, name, label=nil)
    label ||= name.to_s.titleize
    element_present "xpath=//td/label[text()='#{label}']/../span[@class='required'][text()='*']"
    element_present "xpath=//td/input[@id='#{base_type}_#{name}'][@name='#{base_type}[#{name}]']"
  end
  
  # Validates that the default "Required" message exists somewhere on the page
  def required_message
    element_present "xpath=//p[@class='required'][text()='* Required']"
  end  
  
  def quick_add_selected_option(base_type, qa_type, option_text)
    assert_equal option_text, @selenium.get_selected_label("#{base_type.to_s.singularize}_#{qa_type}_id")
  end
  
  def click_quick_add_save
    click "xpath=//*[@id='show_win_quick_add_content']//input[@value='Create']"
    sleep 1 # wait for quick add window to populate select field
  end
  
  def click_quick_add_for(model_class, field_name)
     click "id=sl_qa_#{model_class}_#{field_name}"
     sleep 1 # wait for quick add window to open
  end

  def click_quick_edit_for(model_name, row_text)
    click "//td[text()='#{row_text}']/../td//img[@alt='Edit #{model_name.to_s.humanize.titleize}']"
    sleep 1 # wait for quick add window to open
  end

  def click_quick_edit_save(model_name)   
    # TODO Enhance Streamlined JS to use properly-formated model names 
    # (e.g., "phone_number" instead of "phonenumber") and then we won't need
    # this #{model_name.camelize.downcase} ugliness
    click "xpath=//*[@id='show_win_#{model_name.camelize.downcase}']//input[@value='Save']"
    sleep 2 # wait for quick edit window to populate parent form
  end
  
  def quick_add_window_should_be_gone
    element_not_present 'css=#show_win_quick_add' 
  end
  
  def enter_table_data(table_data)
    do_with_table_data(table_data) { |row| enter_data *row }
  end

  def user_should_see(&blk)
    instance_eval(&blk)
  end
  
  # Validates the data in a "list" view using rows (i.e., arrays) of cell text
  def list_table_with(table_data)
    table_data.each_with_index do |row, i|
      tag = (i > 0) ? "td" : "th"
      error_message = "Expected to find a table row containing: #{row.inspect}"
      locator = "//#{tag}[text()='#{row.shift}']"
      row.each do |cell|
        if cell.strip.blank?
          locator << "/following-sibling::#{tag}"
          flunk(error_message) unless @selenium.get_text(locator).strip.blank?
        else
          locator << "/following-sibling::#{tag}[text()='#{cell}']"
        end
      end
      element_present locator, error_message
    end
  end
  
  # Validates the data in a "show" view using rows of label/value pairs
  def show_table_with(table_data)
    table_data.each do |row|
      value = row[:shows_as] || row[:value]
      field_present "#{row[:label]}:", value
    end
  end

  # Validates the data in an "edit" view using rows of label/value pairs
  def edit_table_with(table_data)
    do_with_table_data(table_data) { |row| input_field_present(*row) }
  end

  def do_with_table_data(table_data, &block)
    table_data.each do |row|
      yield optional_last_arg(row)
    end
  end
  
  # Validates that the specified persona names/ID pairs are listed in a table
  def persona_table_with(persona, *names_and_ids)
    names_and_ids.each do |e|
      assert_equal e[:name], @selenium.get_text("xpath=//tr[@id='#{persona}_#{e[:id]}']/td[1]/span/a")
    end
  end

  private                                  
  # TODO: validate that we are getting reasonable hash
  def optional_last_arg(row)
    result = [row[:label], row[:value]]
    result << row[:input] if row[:input]
    result
  end   
end