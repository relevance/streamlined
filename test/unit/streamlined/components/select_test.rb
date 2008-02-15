require File.expand_path(File.join(File.dirname(__FILE__), '../../../test_helper'))

include Streamlined::Components

describe "Select component" do
  
  it "should fail fast if there are missing args" do
    lambda{Select.render}.should.raise(ArgumentError)
  end

  it "renders a select tag plus a hidden input field with STREAMLINED_SELECT_NONE" do
    view = ActionView::Base.new
    tags = Select.render(:view => view, :object => "person", :method => "friends") do |s|
      s.choices = ["Joe", "John"]
      s.html_options = {:size => 5, :multiple => true}
    end
    html = root_node "<div>#{tags}</div>"
    assert_select html, "select[id=person_friends][size=5]" do |select|
      assert_select "option[value=Joe]", "Joe"
      assert_select "option[value=John]", "John"
    end                                       
    assert_select html, "input[type=hidden][value=#{STREAMLINED_SELECT_NONE}]"
  end
end

