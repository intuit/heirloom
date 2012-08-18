require 'spec_helper'

describe Heirloom do

  before do
    @logger_stub = stub 'logger', :info => true, :debug => true
    @config_mock = mock 'config'
    @config_mock.stub :logger => @logger_stub
    @tempfile_stub = stub 'tempfile', :path => '/tmp/file'
    Tempfile.stub :new => @tempfile_stub
    @extracter = Heirloom::Extracter.new :config => @config_mock
  end

  it "should extract the given archive object into the output directory" do
    File.should_receive(:open).with('/tmp/file', 'w')
    Heirloom::Extracter.any_instance.should_receive(:`).
                        with('tar xzf /tmp/file -C /output')
    File.should_receive(:delete).with '/tmp/file'
    @extracter.extract :archive => 'test', :output => '/output'
  end

end
