require File.join(File.dirname(__FILE__), '../../test_helper')
require 'rake'

class Streamlined::RakeTasksTest < Test::Unit::TestCase
  RAKE_FILE = File.join(File.dirname(__FILE__), '../../../tasks/relevance_extensions_tasks.rake')
  
  def setup
    load RAKE_FILE
    @test_target_directory_root = "#{Dir.tmpdir}/streamlined_test"
    
    @test_target_directory_source = "#{@test_target_directory_root}/src"
    @test_target_directory_destination = "#{@test_target_directory_root}/dest"
    
    @original_source, Streamlined::Assets.source = Streamlined::Assets.source, @test_target_directory_source
    @original_destination, Streamlined::Assets.destination = Streamlined::Assets.destination, @test_target_directory_destination
  end

  def teardown
    Streamlined::Assets.source = @original_source
    Streamlined::Assets.destination = @original_destination
    
    FileUtils.rm_r @test_target_directory_root
    assert_false File.exists?(@test_target_directory_root)
  end
  
  def test_install_skips_svn_directories
    create_directory "#{@test_target_directory_source}/images"
    create_directory @test_target_directory_destination
    
    [".svn", "should_get_copied", "images/should_get_copied.png"].each do |path|
      FileUtils.touch "#{@test_target_directory_source}/#{path}"
    end
    
    Streamlined::Assets.install
    
    assert File.exists?("#{@test_target_directory_destination}/should_get_copied")
    assert File.exists?("#{@test_target_directory_destination}/images/should_get_copied.png")
    assert_false File.exists?("#{@test_target_directory_destination}/.svn")
  end
  
  private
  
  def create_directory(path)
    FileUtils.mkdir_p path unless File.exists? path
  end

end
