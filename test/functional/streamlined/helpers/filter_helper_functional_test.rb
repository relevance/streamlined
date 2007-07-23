require File.join(File.dirname(__FILE__), '../../../test_functional_helper')
require 'streamlined/helpers/filter_helper'

class Streamlined::Helpers::FilterHelperFunctionalTest < Test::Unit::TestCase
  fixtures :people, :poems
  def setup
    stock_controller_and_view
  end
  
  def test_simple_advanced_filter_columns
    advanced_filter_columns = @view.advanced_filter_columns
    assert_equal 3, person_columns = PersonUI.list_columns.length
    assert_equal 2, advanced_filter_columns.length
    assert_equal [["First name", "first_name"],["Last name", "last_name"]], advanced_filter_columns
  end

  # Check that relation columns Articles::title and Books::title get included for filtering
  # and that the UI column "full_name" and relation authorships are excluded
  def test_complex_advanced_filter_columns
    complex_controller_and_view
    advanced_filter_columns = @view.advanced_filter_columns
    author_columns = AuthorUI.list_columns
    assert_equal 6, author_columns = AuthorUI.list_columns.length
    assert_equal 4, advanced_filter_columns.length
    assert_equal [["Articles (title)", "rel::articles::title"],["Books (title)", "rel::books::title"],["First name", "first_name"],["Last name", "last_name"]], advanced_filter_columns
  end
  
  def complex_controller_and_view
#    setup_routes
    ActionController::Routing.use_controllers! %w(people poems)
    @controller = AuthorsController.new
    @controller.logger = RAILS_DEFAULT_LOGGER
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @item = Struct.new(:id).new(1)
    get 'index'
    @view = @response.template
  end
end