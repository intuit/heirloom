require 'spec_helper'

describe Heirloom do

  before do
    @logger_stub = stub 'logger', :info => true, :debug => true
    @config_mock = mock 'config'
    @config_mock.stub :logger => @logger_stub
    @tempfile_stub = stub 'tempfile', :path => '/tmp/tempfile'
    Tempfile.stub :new => @tempfile_stub
    @writer = Heirloom::Writer.new :config => @config_mock
  end

  context "extract set to true" do
    it "should extract the given archive object into the output directory" do
      File.should_receive(:open).with('/tmp/tempfile', 'w')
      Heirloom::Writer.any_instance.should_receive(:`).
                       with('tar xzf /tmp/tempfile -C /output')
      @writer.save_archive :archive => 'archive_data', 
                           :output  => '/output',
                           :file    => 'id.tar.gz',
                           :extract => true
    end
  end

  context "extract set to false" do
    it "should save the given archive object into the output directory" do
      File.should_receive(:open).with('/output/id.tar.gz', 'w')
      @writer.save_archive :archive => 'archive_data', 
                           :output  => '/output',
                           :file    => 'id.tar.gz',
                           :extract => false
    end
  end

end
