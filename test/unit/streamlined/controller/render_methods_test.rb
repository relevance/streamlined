require File.join(File.dirname(__FILE__), '../../../test_helper')
require 'streamlined/controller/render_methods'

class Streamlined::Controller::RenderMethodsTest < Test::Unit::TestCase
  include Streamlined::Controller::RenderMethods
  attr_accessor :instance, :render_filters
  
  # begin stub methods
  def controller_name
    "people"
  end
  
  def managed_views_include?(action)
    true
  end

  def managed_partials_include?(action)
    true
  end
  
  def params
    { :action => 'edit' }
  end
  
  def render_filters
    @render_filters || {}
  end
  # end stub methods
  
  def test_render_or_redirect_with_render
    (@instance = flexmock).should_receive(:id).and_return(123).once
    flexmock(self).should_receive(:respond_to).once  # not sure how to test blocks w/flexmock?
    render_or_redirect(:success, 'show')
    assert_equal 123, @id
  end
  
  def test_render_or_redirect_with_redirect
    (@instance = flexmock).should_receive(:id).and_return(123).once
    (request = flexmock).should_receive(:xhr?).and_return(false).once
    flexmock(self) do |mock|
      mock.should_receive(:request).and_return(request).once
      mock.should_receive(:redirect_to).with(:redirect_to => 'show').once
    end
    render_or_redirect(:success, nil, :redirect_to => 'show')
    assert_equal 123, @id
  end
  
  def test_render_or_redirect_with_render_filter_proc
    (@instance = flexmock).should_receive(:id).and_return(123).once
    (proc = flexmock).should_receive(:is_a?).with(Proc).and_return(true).once
    proc.should_receive(:call).once
    @render_filters = { :edit => { :success => proc }}
    render_or_redirect(:success, 'show')
    assert_equal 123, @id
  end
  
  def test_execute_render_filter_with_proc
    (proc = flexmock).should_receive(:is_a?).with(Proc).and_return(true).once
    proc.should_receive(:call).once
    execute_render_filter(proc)
  end
  
  def test_execute_render_filter_with_render_tabs
    flexmock(self).should_receive(:render_tabs).with(:foo, :bar, [:bat, 'ball']).once
    execute_render_filter(:render_tabs => [:foo, :bar, [:bat, 'ball']])
  end
  
  def test_execute_render_filter_with_render
    flexmock(self).should_receive(:render).with(:text => 'hello world').once
    execute_render_filter(:render => { :text => 'hello world' })
  end
  
  def test_execute_render_filter_with_redirect
    flexmock(self).should_receive(:redirect_to).with(:action => 'somewhere').once
    execute_render_filter(:redirect_to => { :action => 'somewhere'})
  end
  
  def test_execute_render_filter_with_instance
    instance = flexmock(:bond => 'the bond')
    flexmock(self) do |mock|
      mock.should_receive(:instance).and_return(instance).once
      mock.should_receive(:render).with('nothing').once
    end
    execute_render_filter(:with_instance => :bond, :render => 'nothing')
  end
  
  def pretend_template_exists(exists)
    flexstub(self) do |stub|
      stub.should_receive(:specific_template_exists?).and_return(exists)
    end
  end
  
  def test_convert_partial_options_for_generic
    pretend_template_exists(false)
    options = {:partial=>"list", :other=>"1"}
    convert_partial_options(options)
    assert_equal({:layout=>false, :template=>"../../../templates/generic_views/_list", :other=>"1"}, options)
  end

  def test_convert_partial_options_and_layout_for_generic
    pretend_template_exists(false)
    options = {:partial=>"list", :other=>"1", :layout=>true}
    convert_partial_options(options)
    assert_equal({:layout=>true, :template=>"../../../templates/generic_views/_list", :other=>"1"}, options)
  end

  def test_convert_partial_options_for_specific
    pretend_template_exists(true)
    options = {:partial=>"list", :other=>"1"}
    convert_partial_options(options)
    assert_equal({:partial=>"list", :other=>"1"}, options)
  end
end