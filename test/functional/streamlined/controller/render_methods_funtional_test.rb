require File.join(File.dirname(__FILE__), '../../../test_functional_helper')
require 'streamlined/controller/render_methods'

class RenderMethodsFunctionalTest < Test::Unit::TestCase
  FILES_CONTENTS = { 'Foo/_file1' => 'content1', 'Foo/_file2' => 'content2', 'Foo/../shared/dir/_foo' => 'content3', '../shared/dir/foo' => 'content3' }

  class FooController < ActionController::Base
    acts_as_streamlined
    attr_reader :rendered
    def render_to_string(hash)
      @locals = hash[:locals]
      return FILES_CONTENTS[hash[:partial].to_s] if hash[:partial]
      FILES_CONTENTS[hash[:template].to_s] if hash[:template]
    end
    def render(hash)
      @rendered = hash[:text]
    end
    
    public :render_tabs, :render_partials, :partial_name
  end
  
  class ::Foo < ActiveRecord::Base
  end

  def setup
    @controller = FooController.new
    @controller.params = { :controller => 'Foo' }
  end

  def test_render_partials
    assert_equal 'content1', @controller.render_partials('file1')
    assert_equal 'content1content2', @controller.render_partials('file1', 'file2')
  end

  def test_render_tabs
    response = @controller.render_tabs({:name => 'tab1', :partial => 'file1' }, {:name => 'tab2', :partial => 'file2'})
    #doc = REXML::Document.new(response)
    # assert_equal "tabber", doc.root.elements["/div[1]/@class"].value

    assert response =~ /tab1/
    assert response =~ /tab2/
    assert response =~ /<div class='tabber'>/
    assert response =~ /<div class='tabbertab'/
  end

  def test_render_tabs_in_order
    response = @controller.render_tabs({:name => 'tab1', :partial => :file1}, {:name => 'tab2', :partial => :file2})
    assert response =~ /id='tab1'.*id='tab2'/
  end

  def test_render_tabs_with_missing_args
    results = assert_raise(ArgumentError) {
      response = @controller.render_tabs({:name => 'tab1'})
    }
    assert_equal ':partial is required', results.message
    results = assert_raise(ArgumentError) {
      response = @controller.render_tabs({:partial => '../shared/dir/foo'})
    }
    assert_equal ':name is required', results.message
  end

  def test_render_tabs_with_shared_partial
    response = @controller.render_tabs({:name => 'tab1', :partial => '../shared/dir/foo'})

    assert response =~ /tab1/
    assert response =~ /tabber/
    assert response =~ /tabbertab/
    assert response =~ /content3/
  end
  
  def test_render_partials
   response = @controller.render_partials('../shared/dir/foo')
   assert response =~ /^content3/
  end
  
  def test_render_tabs_with_partial_and_locals
    response = @controller.render_tabs({:name => 'tab1', :partial => '../shared/dir/foo', :locals => 'something'})

    assert response =~ /tab1/
    assert response =~ /tabber/
    assert response =~ /tabbertab/
    assert response =~ /content3/
    
    assert @locals = 'something'
  end
  
  def test_partial_name_should_not_change_file_name_when_it_contains_slash
    file_name = 'Foo/_file2'
    @controller.partial_name(file_name)
    assert_equal 'Foo/_file2', file_name
  end  
end