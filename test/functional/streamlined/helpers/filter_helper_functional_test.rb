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
    assert_equal [["Articles (Title)", "rel::articles::title"],["Books (Title)", "rel::books::title"],["First name", "first_name"],["Last name", "last_name"]], advanced_filter_columns
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
  
  # Check that relation columns Authors::last_name and Authors::first_name get included for filtering
  # and that Authors::full_name does not since it is not a db field, just a define in Author.rb 
  def test_advanced_filter_columns_with_fields
    @controller = ArticlesController.new
    @controller.logger = RAILS_DEFAULT_LOGGER
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @item = Struct.new(:id).new(1)
    get 'index'
    @view = @response.template
    @article_ui = Streamlined.ui_for(Article)
    
    advanced_filter_columns = @view.advanced_filter_columns
    article_columns = @article_ui.list_columns
    assert_equal 2, article_columns = @article_ui.user_columns.length, "Should only have 2 list_columns in ArticlesUI file"
    assert_equal 3, @article_ui.relationships[:authors].show_view.fields.length, "Testing that there are 3 fields of which 2 will be picked.  Check for changes in ArticlesUI file."
    assert_equal [:first_name, :last_name, :full_name], @article_ui.relationships[:authors].show_view.fields, "Testing that there are 3 fields of which 2 will be picked.  Check for changes in ArticlesUI file."
    assert_equal 3, advanced_filter_columns.length, "Should have 3 columns to filter on Author-last_name, Author-first_name and Title"
    assert_equal [["Authors (First name)", "rel::authors::first_name"],["Authors (Last name)", "rel::authors::last_name"],["Title", "title"]], advanced_filter_columns, "Should have 3 columns to filter on Author-last_name, Author-first_name and Title"
  end
  
end