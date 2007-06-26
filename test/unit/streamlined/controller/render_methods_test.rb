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
    flexmock(self).should_receive(:instance_eval).at_least.once
    @render_filters = { :edit => { :success => Proc.new { render :text => 'hello world' }}}
    render_or_redirect(:success, 'show')
    assert_equal 123, @id
  end
  
  def test_execute_render_filter_with_proc
    proc = Proc.new { render :text => 'hello world' }
    flexmock(self).should_receive(:instance_eval).at_least.once
    # TODO: why isn't this working?
    #flexmock(self).should_receive(:render).with(:text => 'hello world').once
    execute_render_filter(proc)
  end
  
  def test_execute_render_filter_with_symbol
    flexmock(self).should_receive(:method_to_invoke).once
    execute_render_filter(:method_to_invoke)
  end
  
  def test_execute_render_filter_with_invalid_args
    assert_raises(ArgumentError) { execute_render_filter("bad_args")}
  end
  
  def pretend_template_exists(exists)
    flexstub(self).should_receive(:specific_template_exists?).and_return(exists)
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
  
  def test_render_partials_with_tabs
    flexstub(self) do |stub|
      stub.should_receive(:render_tabs_to_string).with(1,2,3).returns("render_result")
      stub.should_receive(:render).with(:text=>"render_result", :layout=>true)
    end
    render_partials(:tabs=>[1,2,3])
  end

  def test_render_partials_without_tabs
    flexstub(self) do |stub|
      stub.should_receive(:render_to_string).with({}).returns("render_result")
      stub.should_receive(:render).with(:text=>"render_result", :layout=>true)
    end
    render_partials({})
  end
  
  
end