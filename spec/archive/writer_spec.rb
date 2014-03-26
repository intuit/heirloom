require 'spec_helper'

describe Heirloom do

  before do
    @logger_double = double 'logger'
    @logger_double.stub :info => true, :debug => true
    @config_double = double 'config'
    @config_double.stub :logger => @logger_double
    @tempfile_double = double 'tempfile', :path => '/tmp/tempfile'
    Tempfile.stub :new => @tempfile_double
    @writer = Heirloom::Writer.new :config => @config_double
  end

  context "extract is set to true" do
    it "should extract the given archive object into the output directory" do
      File.should_receive(:open).with('/tmp/tempfile', 'w')
      Heirloom::Writer.any_instance.should_receive(:`).
                       with('tar xzf /tmp/tempfile -C /output')
      $?.stub :success? => true
      @writer.save_archive(:archive => 'archive_data', 
                           :output  => '/output',
                           :file    => 'id.tar.gz',
                           :extract => true).should be_true
    end

    it "should return false if the extract fails" do
      File.should_receive(:open).with('/tmp/tempfile', 'w')
      Heirloom::Writer.any_instance.should_receive(:`).
                       with('tar xzf /tmp/tempfile -C /output')
      $?.stub :success? => false
      @logger_double.should_receive(:error)
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
