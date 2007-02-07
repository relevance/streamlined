require File.join(File.dirname(__FILE__), '../test_functional_helper')
require 'active_record_extensions'

class ActiveRecordExtensionsTest < Test::Unit::TestCase
  fixtures :people, :poets, :poems
  
  def test_find_by_like
    assert_equal [people(:justin)], Person.find_by_like('Just', Person.user_columns)
    assert_equal [people(:justin)], Person.find_by_like('land', Person.user_columns)
    assert_equal [], Person.find_by_like('wibble', Person.user_columns)
  end
  
  def test_has_manies
    assert_equal 1, Poet.has_manies.size
    assert_equal 0, Person.has_manies.size
  end
  
  def test_has_ones
    assert_equal 1, Poet.has_ones.size
    assert_equal 0, Person.has_ones.size
  end
end
