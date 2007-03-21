require File.join(File.dirname(__FILE__), '../../../test_helper')
require 'streamlined/column/addition'

class Streamlined::Column::ActiveRecordTest < Test::Unit::TestCase
  include Streamlined::Column
  
  def test_equal
    a1 = ActiveRecord.new(:foo)
    a2 = ActiveRecord.new(:foo)
    a3 = ActiveRecord.new(:bar)
    a4 = ActiveRecord.new(nil)
    assert_equal a1, a2
    assert_not_equal a1, a3
    assert_not_equal a4, a1
  end
end