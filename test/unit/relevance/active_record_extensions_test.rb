require File.expand_path(File.join(File.dirname(__FILE__), '../../test_helper'))
require 'relevance/active_record_extensions'

describe "ActiveRecordExtensions" do
  
  def setup
    @inst = Object.new
    @cls = Object.new
    @inst.extend(Relevance::ActiveRecordExtensions::InstanceMethods)
    @cls.extend(Relevance::ActiveRecordExtensions::ClassMethods)
  end
  
  it "streamlined name" do
    flexstub(@inst).should_receive(:id).and_return('my_id')
    assert_equal('my_id', @inst.streamlined_name)
    flexstub(@inst).should_receive(:title).and_return('my_title')
    assert_equal('my_title', @inst.streamlined_name)
    flexstub(@inst).should_receive(:name).and_return('my_name')
    assert_equal('my_name', @inst.streamlined_name)
    assert_equal('my_title:my_id', @inst.streamlined_name([:title,:id]))
    assert_equal('my_title-my_id', @inst.streamlined_name([:title,:id], '-'))
  end
  
  it "user columns" do
    s = Struct.new(:name)
    flexstub(@cls).should_receive(:content_columns).and_return do
      %w{_at _on position alpha lock_version _id password_hash beta}.map{|name| s.new(name)}
    end
    assert_equal %w{alpha beta}, @cls.user_columns.map(&:name)
  end
  
  it "returns streamlined css id" do
    @inst.stubs(:id).returns(123)
    @inst.streamlined_css_id.should == "object_123"
  end
  
end
