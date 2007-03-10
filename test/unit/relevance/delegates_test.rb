require File.dirname(__FILE__) + '/../../test_helper'
require 'relevance/delegates'

class ModuleDelegatesTest < Test::Unit::TestCase
  include FlexMock::TestCase
  class TestMe
    attr_accessor :helper
    delegates :jump, :to=>:helper
    delegates :run, :to=>:helper, :default=>''
    delegates :fly, :zoom, :to=>:helper, :method=>:soar
  end
  
  def test_default
    t = TestMe.new
    assert_equal '', t.run
    t.helper = flexmock("helper") 
    t.helper.should_receive(:run).and_return(0)
    assert_equal 0, t.run
  end
  
  def test_method
    t = TestMe.new
    t.helper = flexmock("helper")
    t.helper.should_receive(:soar).and_return(:done)
    assert_equal(:done, t.fly)
    assert_equal(:done, t.zoom)
  end
  
  def test_plain
    t = TestMe.new
    assert_raise(NoMethodError) {t.jump}
    t.helper = flexmock("helper")
    t.helper.should_receive(:jump).and_return(nil)
    assert_nil t.jump 
  end
end


