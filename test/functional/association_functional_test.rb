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
    html = @association.render_quick_add(@view)
    assert_match %r{id="sl_qa_poet_poet"}, html
    assert_match %r{class="sl_quick_add_link"}, html
    
    # TODO: these next three lines used to be a single assertion, but it was failing on the command line
    # due to the params being out of order (it ran just fine in TextMate). If the assertion is rewritten
    # again on one line, it should not be sensetive to the order of the params in the URL. (MJB)
    assert_match %r{<a href="/people/quick_add\?}, html
    assert_match %r{model_class_name=Poet}, html
    assert_match %r{select_id=poem_poet_id}, html
  end
  
end