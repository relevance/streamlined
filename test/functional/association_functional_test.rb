require File.join(File.dirname(__FILE__), '../test_functional_helper')
include Streamlined::Column

class AssociationFunctionalTest < Test::Unit::TestCase
  fixtures :poets, :poems

  def test_associables_for_non_polymorphic_association
    @association = Association.new(Poet.reflect_on_association(:poems), Poet, :inset_table, :count)
    assert_equal [Poem], @association.associables
  end

  def test_associables_for_polymorphic_association
    @association = Association.new(Authorship.reflect_on_association(:publication), Author, :inset_table, :count)
    assert_equal_sets [Book, Article], @association.associables
  end
end