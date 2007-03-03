require File.join(File.dirname(__FILE__), '../test_helper')
require 'streamlined_helper'

class StreamlinedHelperTest < Test::Unit::TestCase
  include FlexMock::TestCase
  include StreamlinedHelper

  def column_named_name
    column = flexmock("column")
    column.should_expect do |o|
      o.human_name.returns("name")
    end
    column
  end
  
  def test_column_sort_image_up
    options = flexmock("options")
    options.should_expect do |o|
      o.sort_column.returns("name")
      o.ascending?.returns(true)
    end
    flexstub(self).should_receive(:image_tag).with("streamlined/arrow-up_16.png", Hash).and_return("testing up")
    assert_equal("testing up", column_sort_image(options,column_named_name))
  end

  def test_column_sort_image_down
    options = flexmock("options")
    options.should_expect do |o|
      o.sort_column.returns("name")
      o.ascending?.returns(false)
    end
    flexstub(self).should_receive(:image_tag).with("streamlined/arrow-down_16.png", Hash).and_return("testing down")
    assert_equal("testing down", column_sort_image(options,column_named_name))
  end

  def test_column_sort_image_none
    options = flexmock("options")
    options.should_expect do |o|
      o.sort_column.returns("foo")
    end
    assert_equal("", column_sort_image(options,column_named_name))
  end
end
