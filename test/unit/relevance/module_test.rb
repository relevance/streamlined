require File.dirname(__FILE__) + '/../../test_helper'

class Relevance::ModuleExtensionsTest < Test::Unit::TestCase
  def callme(*args); "foo"; end
    
  def test_wrap_method
    assert_equal "foo", self.callme
    assert_equal "foo", self.callme(1)
    self.class.wrap_method :callme do |old_meth, args|
      return args.size if args && args.size > 0
      old_meth.call
    end
    assert_equal "foo", self.callme
    assert_equal 1, self.callme(1)
  end
end
