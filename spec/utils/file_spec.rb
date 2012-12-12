require 'spec_helper'

describe Heirloom::Utils::File do
  before do
    @object = Object.new
    @object.extend Heirloom::Utils::File
  end

  it "should return the path to a present executable" do
    @object.stub :path => '/test1:/test2'
    ::File.should_receive(:executable?).
           with('/test1/test1234').
           and_return false
    ::File.should_receive(:executable?).
           with('/test2/test1234').
           and_return true
    @object.which('test1234').should == '/test2/test1234'
  end

  it "should return nil if the executable does not exist" do
    @object.stub :path => '/test1:/test2'
    ::File.should_receive(:executable?).
           with('/test1/test1234').
           and_return false
    ::File.should_receive(:executable?).
           with('/test2/test1234').
           and_return false
    @object.which('test1234').should be_nil
  end
end
