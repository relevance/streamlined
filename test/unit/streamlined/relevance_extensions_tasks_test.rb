require File.join(File.dirname(__FILE__), '../../test_helper')
require 'rake'

class Streamlined::RakeTasksTest < Test::Unit::TestCase
  RAKE_FILE = File.join(File.dirname(__FILE__), '../../../tasks/relevance_extensions_tasks.rake')
  
  def setup
    @rake = Rake::Application.new
    Rake.application = @rake
    load RAKE_FILE
  end

  def test_should_have_asset_arrays
    assert_not_nil Streamlined::Assets.default_javascripts
    assert_not_nil Streamlined::Assets.default_stylesheets
    assert_not_nil Streamlined::Assets.default_layout
  end

  def test_should_copy_required_javascripts
    expected_dest = File.join(RAILS_ROOT, "public", "javascripts")
    Streamlined::Assets.default_javascripts.each do |javascript| 
      flexmock(Streamlined::Assets).should_receive(:copy).once.
        with(Streamlined::Assets.normalize_asset(javascript), expected_dest).and_return(nil)
    end
    flexmock(Streamlined::Assets).should_receive(:copy).once.
      with(Streamlined::Assets.normalize_asset("overlib"), expected_dest).and_return(nil)
    flexmock(Streamlined::Assets).should_receive(:copy).once.
      with(Streamlined::Assets.normalize_asset("windows_js"), expected_dest).and_return(nil)
      
    Streamlined::Assets.install_javascripts
  end
  
  def test_should_copy_required_stylesheets
    Streamlined::Assets.default_stylesheets.each do |file| 
      expected_dest = File.join(RAILS_ROOT, "public", "stylesheets")
      flexmock(Streamlined::Assets).should_receive(:copy).once.
        with(Streamlined::Assets.normalize_asset(file), expected_dest).and_return(nil)
    end
    Streamlined::Assets.install_stylesheets
  end
  
  def test_should_copy_required_layout
    expected_dest = File.join(RAILS_ROOT, "app", "views", "layouts")
    flexmock(Streamlined::Assets).should_receive(:copy).once.
      with(Streamlined::Assets.normalize_asset("streamlined.rhtml"), expected_dest).and_return(nil)
    Streamlined::Assets.install_layout
  end
  
  def test_should_copy_images
    expected_dest = File.join(RAILS_ROOT, "public", "images", "streamlined")
    flexmock(FileUtils).should_receive(:cp_r).once.
      with(Streamlined::Assets.normalize_asset("images"), expected_dest).and_return(nil)
    Streamlined::Assets.install_images
  end
  
  def test_should_copy_partials
    expected_dest = File.join(RAILS_ROOT, "app", "views", "shared", "streamlined")
    flexmock(FileUtils).should_receive(:cp_r).once.
      with(Streamlined::Assets.normalize_asset("partials"), expected_dest).and_return(nil)
    Streamlined::Assets.install_partials
  end
end
