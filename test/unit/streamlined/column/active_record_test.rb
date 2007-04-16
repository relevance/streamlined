require File.join(File.dirname(__FILE__), '../../../test_helper')
require 'streamlined/column/addition'

class Streamlined::Column::ActiveRecordTest < Test::Unit::TestCase
  include Streamlined::Column
  include FlexMock::TestCase
  
  def test_names_delegate_to_ar_column
    ar = ActiveRecord.new(ar_column('foo_bar', 'Foo bar'))
    assert_equal 'foo_bar', ar.name
    assert_equal 'Foo bar', ar.human_name
  end
  
  def test_human_name_can_be_set_manually
    ar = ActiveRecord.new(ar_column('foo_bar', 'Foo bar'))
    ar.human_name = 'Bar Foo'
    assert_equal 'Bar Foo', ar.human_name
  end
  
  def test_equal
    a1 = ActiveRecord.new(:foo)  
    a2 = ActiveRecord.new(:foo)
    a3 = ActiveRecord.new(:bar)
    a4 = ActiveRecord.new(nil)
    assert_equal a1, a2
    assert_not_equal a1, a3
    assert_not_equal a4, a1
  end
  
  def ar_column(name, human_name)
    ar_column = flexmock
    ar_column.should_receive(:name).and_return(name)
    ar_column.should_receive(:human_name).and_return(human_name)
    ar_column
  end
end