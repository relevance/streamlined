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
  
  # TODO: make QuickAdd JavaScript unobtrusive
  def test_render_quick_add
    stock_controller_and_view
    @association = Association.new(Poem.reflect_on_association(:poet), Poem, :inset_table, :count) 
    result = <<-END
<a href="#" onclick="Streamlined.QuickAdd.open('/people/quick_add?model_class_name=Poet&amp;select_id=poem_poet_id'); return false;"><img alt="Quick Add" border="0" hspace="2" id="sl_qa_Poet_poet" src="/images/streamlined/add_16.png" title="Quick Add" /></a>
END
    assert_equal result.chop, @association.render_quick_add(@view)
  end
  
end