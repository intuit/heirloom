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
      git_dir_mock = double "git directory mock"
      git_commit_mock = double "git commit mock"
      @logger_mock.should_receive(:info).exactly(5).times
      Heirloom::Directory.should_receive(:new).with(:path    => 'path_to_build',
                                                    :exclude => ['.dir_to_exclude'],
                                                    :config  => @config_mock).
                                               and_return(directory_mock)
      directory_mock.should_receive(:build_artifact_from_directory).
                     and_return '/tmp/file'
      directory_mock.should_receive(:local_build).and_return('/tmp/file')
      @builder.should_receive(:create_artifact_record)
      Heirloom::GitDirectory.should_receive(:new).
                             with(:path => 'path_to_build').
                             and_return git_dir_mock
      git_dir_mock.should_receive(:commit).
                   with('123').and_return git_commit_mock
      git_commit_mock.should_receive(:id_abbrev).exactly(2).times.
                      and_return 'abc123'
      git_commit_mock.should_receive(:message).exactly(2).times.
                      and_return 'yoyo'
      author_mock = double "git commit author mock"
      git_commit_mock.should_receive(:author).exactly(2).times.
                     and_return author_mock
      author_mock.should_receive(:name).exactly(2).times.
                  and_return 'weaver'
      commit_attributes = { 'sha'             => '123',
                            'abbreviated_sha' => 'abc123',
                            'message'         => 'yoyo',
                            'author'          => 'weaver' }
      @simpledb_mock.should_receive(:put_attributes).
                     with('tim', '123', commit_attributes)

      @builder.build(:exclude   => ['.dir_to_exclude'],
                     :directory => 'path_to_build',
                     :git       => 'true').should == '/tmp/file'
    end

    it "should build an archive and log a warning if the git sha is not found" do
      directory_mock = double "directory"
      git_dir_mock = double "git directory mock"
      git_commit_mock = double "git commit mock"
      @logger_mock.should_receive(:info).exactly(1).times
      @logger_mock.should_receive(:warn).exactly(1).times
      Heirloom::Directory.should_receive(:new).with(:path    => 'path_to_build',
                                                    :exclude => ['.dir_to_exclude'],
                                                    :config  => @config_mock).
                                               and_return(directory_mock)
      directory_mock.should_receive(:build_artifact_from_directory).
                     and_return '/tmp/file'
      directory_mock.should_receive(:local_build).and_return('/tmp/file')
      @builder.should_receive(:create_artifact_record)
      Heirloom::GitDirectory.should_receive(:new).
                             with(:path => 'path_to_build').
                             and_return git_dir_mock
      git_dir_mock.should_receive(:commit).
                   with('123').and_return false
      @builder.build(:exclude   => ['.dir_to_exclude'],
                     :directory => 'path_to_build',
                     :git       => 'true').should == '/tmp/file'
    end


    it "should return false if the build fails" do
      directory_mock = double "directory"
      Heirloom::Directory.should_receive(:new).with(:path    => 'path_to_build',
                                                    :exclude => ['.dir_to_exclude'],
                                                    :config  => @config_mock).
                                               and_return(directory_mock)
      directory_mock.should_receive(:build_artifact_from_directory).
                     and_return false
      @builder.build(:exclude   => ['.dir_to_exclude'],
                     :directory => 'path_to_build',
                     :git       => 'true').should be_false
    end

    it "should cleanup the local archive" do
      @builder.local_build = '/tmp/file'
      @logger_mock.should_receive(:info).with("Cleaning up local build /tmp/file.")
      File.should_receive(:delete).with('/tmp/file')
      @builder.cleanup
    end

end
