require 'spec_helper'

describe Heirloom do

    before do
      @config_mock = double 'config'
      @logger_mock = double 'logger'
      @simpledb_mock = double 'simple db'
      @config_mock.should_receive(:logger).and_return(@logger_mock)
      Heirloom::AWS::SimpleDB.should_receive(:new).with(:config => @config_mock).
                              and_return(@simpledb_mock)
      @simpledb_mock.should_receive(:create_domain).with 'tim'
      @builder = Heirloom::Builder.new :config => @config_mock,
                                               :name   => 'tim',
                                               :id     => '123'
    end

    it "should build an archive" do
      directory_mock = double "directory"
      Heirloom::Directory.should_receive(:new).with(:path    => 'path_to_build',
                                                    :exclude => ['.dir_to_exclude'],
                                                    :config  => @config_mock).
                                               and_return(directory_mock)
      directory_mock.should_receive :build_artifact_from_directory
      directory_mock.should_receive(:local_build).and_return('/tmp/file')
      @builder.should_receive(:create_artifact_record)
      @builder.should_receive(:add_git_commit)
      @logger_mock.should_receive(:info).with("Build complete.")
      @builder.build(:exclude   => ['.dir_to_exclude'],
                     :directory => 'path_to_build',
                     :git       => 'true').should == '/tmp/file'
    end

    it "should cleanup the local archive" do
      @builder.local_build = '/tmp/file'
      @logger_mock.should_receive(:info).with("Cleaning up local build /tmp/file.")
      File.should_receive(:delete).with('/tmp/file')
      @builder.cleanup
    end

end
