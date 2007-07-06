require File.join(File.dirname(__FILE__), '../../test_functional_helper')
require 'relevance/macro_reflection'

class Relevance::ActiveRecord::MacroReflectionTest < Test::Unit::TestCase
  def test_has_many
    assoc = Poet.reflect_on_association(:poems)
    assert_true assoc.has_many?
    assert_false assoc.has_one?
    assert_false assoc.belongs_to?
    assert_false assoc.has_and_belongs_to_many?
  end
  def test_belongs_to
    assoc = Poem.reflect_on_association(:poet)
    assert_false assoc.has_many?
    assert_false assoc.has_one?
    assert_true assoc.belongs_to?
    assert_false assoc.has_and_belongs_to_many?
  end
end