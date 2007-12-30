require File.join(File.dirname(__FILE__), '../test_functional_helper')
require 'relevance/active_record_extensions'

describe "ActiveRecordExtensions" do
  fixtures :people, :poets, :poems
  
  it "can find by like" do
    assert_equal [people(:justin)], Person.find_by_like('Just', Person.user_columns)
    assert_equal [people(:justin)], Person.find_by_like('land', Person.user_columns)
    assert_equal [], Person.find_by_like('wibble', Person.user_columns)
  end
  
  it "gets the correct number of has many relationships" do
    assert_equal 1, Poet.has_manies.size
    assert_equal 0, Person.has_manies.size
  end
  
  it "can exclude has_many_through when getting has many relationships" do
    Author.has_manies(:exclude_has_many_throughs => true).should == [Author.reflect_on_association(:authorships)]
  end
  
  it "has ones" do
    assert_equal 0, Poet.has_ones.size
    assert_equal 0, Person.has_ones.size
  end
  
  it "find by criteria" do
    assert_equal Person.count, Person.find_by_criteria(Person.new).size
    assert_equal [people(:justin)], 
                 Person.find_by_criteria(Person.new(:first_name=>'usti'))
  end
  
  # The doubling ('%%') is to work around Rails. Some of Rails Connection.quote
  # code paths call sprintf, others do not. 
  it "conditions by like" do
    expected = %q{first_name LIKE '%%in \\'quotes\\'%%' OR last_name LIKE '%%in \\'quotes\\'%%'}
    assert_equal expected, Person.conditions_by_like("in 'quotes'")
    assert_equal expected, Person.conditions_by_like("in 'quotes'", Person.user_columns)
    assert_equal expected, Person.conditions_by_like("in 'quotes'", [:first_name, :last_name])
  end
end
