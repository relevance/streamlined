require File.dirname(__FILE__) + '/../../test_helper'
require 'relevance/symbol_additions'

class Relevance::SymbolAdditionsTest < Test::Unit::TestCase
  def test_titleize
    assert_equal "Foo", :foo.titleize
    assert_equal "Foo Bar", :foo_bar.titleize
  end
end
