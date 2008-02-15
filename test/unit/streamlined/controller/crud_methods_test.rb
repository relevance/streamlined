require File.expand_path(File.join(File.dirname(__FILE__), '../../../test_helper'))
require 'streamlined/controller/crud_methods'

describe "Streamlined::Controller::CrudMethods" do

  before do
    @controller = OpenStruct.new
    @controller.extend Streamlined::Controller::CrudMethods
  end
  
  it "should strip out STREAMLINED_SELECT_NONE when setting has_manies" do
    hash = {:foo => ["1", STREAMLINED_SELECT_NONE]}
    @controller.instance = stub_everything
    @controller.instance.expects(:foo).with(["1"])
    @controller.send(:set_has_manies, hash)
  end

end