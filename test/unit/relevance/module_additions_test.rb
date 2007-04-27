require File.dirname(__FILE__) + '/../../test_helper'

class Relevance::ModuleAdditionsTest < Test::Unit::TestCase
  
  class TestMe
    attr_accessor :helper
    delegates :jump, :to=>:helper
    delegates :run, :to=>:helper, :default=>''
    delegates :fly, :zoom, :to=>:helper, :method=>:soar
    delegates :secret, :hidden, :to=>:helper, :visibility=>:private
  end
  
  def test_visibility
    t = TestMe.new
    assert_has_public_methods(t, :jump, :run, :fly)
    assert_has_private_methods(t, :secret, :hidden)
  end
  
  def test_bad_options
    assert_raise(ArgumentError) do 
      Class.new do
        delegates :oops
      end
    end
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
  
  class TestModuleAdditions
    attr_with_default :a, ":alpha"
    attr_with_default(:b) {:beta}
  end
  
  def test_attr_with_default
    t = TestModuleAdditions.new
    assert_equal :alpha, t.a
    assert_equal :beta, t.b
    t.a = nil
    t.b = nil
    assert_nil t.a
    assert_nil t.b
  end
  
end


