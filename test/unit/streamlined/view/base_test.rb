require File.join(File.dirname(__FILE__), '../../../test_helper')
require 'streamlined/view/base'

class Streamlined::View::BaseTest < Test::Unit::TestCase
  class Subclass < Streamlined::View::Base; end
  
  def setup
    @base = Streamlined::View::Base.new
  end
  
  def test_id_fragment
    assert_equal "Base", @base.id_fragment
    c = Class.new(Streamlined::View::Base)
    assert_equal "Subclass", Subclass.new.id_fragment
  end
  
  def test_partial
    assert_equal "../../vendor/plugins/streamlined/templates/relationships/view/base", @base.partial
  end
end