require 'spec_helper'

describe Heirloom do

  before do
    @logger_mock = mock 'logger'
    @logger_mock.stub :info => true, :debug => true
    @config_mock = mock 'config'
    @config_mock.stub :logger => @logger_mock
    @tempfile_stub = stub 'tempfile', :path => '/tmp/tempfile'
    Tempfile.stub :new => @tempfile_stub
    @writer = Heirloom::Writer.new :config => @config_mock
  end

  context "extract is set to true" do
    it "should extract the given archive object into the output directory" do
      File.should_receive(:open).with('/tmp/tempfile', 'w')
      Heirloom::Writer.any_instance.should_receive(:`).
                       with('tar xzf /tmp/tempfile -C /output')
      $?.should_receive(:success?).and_return true
      @writer.save_archive(:archive => 'archive_data', 
                           :output  => '/output',
                           :file    => 'id.tar.gz',
                           :extract => true).should be_true
    end

    it "should return false if the extract fails" do
      File.should_receive(:open).with('/tmp/tempfile', 'w')
      Heirloom::Writer.any_instance.should_receive(:`).
                       with('tar xzf /tmp/tempfile -C /output')
      @logger_mock.should_receive(:error).with "Error extracting archive."
      $?.should_receive(:success?).and_return false
      @writer.save_archive(:archive => 'archive_data', 
                           :output  => '/output',
                           :file    => 'id.tar.gz',
                           :extract => true).should be_false
    end
  end

  context "extract is set to false" do
    it "should save the given archive object into the output directory" do
      File.should_receive(:open).with('/output/id.tar.gz', 'w').
           and_return true
      @writer.save_archive :archive => 'archive_data', 
                           :output  => '/output',
                           :file    => 'id.tar.gz',
                           :extract => false
    end
  end

end
