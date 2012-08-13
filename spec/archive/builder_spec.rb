require 'spec_helper'

describe Heirloom::Builder do
  before do
    @config_mock   = double 'config'
    @logger_stub   = stub :debug => 'true', :info => 'true', :warn => 'true'
    @config_mock.stub(:logger).and_return(@logger_stub)
    @simpledb_mock = double 'simple db'
    Heirloom::AWS::SimpleDB.should_receive(:new).with(:config => @config_mock).
                            and_return(@simpledb_mock)
    @simpledb_mock.should_receive(:create_domain).with 'heirloom_tim'
    @builder       = Heirloom::Builder.new :config => @config_mock,
                                           :name   => 'tim',
                                           :id     => '123'
  end

  describe 'build' do
    before do
      @author_stub    = stub :name => 'weaver'
      @directory_stub = stub :build_artifact_from_directory => '/tmp/build_dir',
                             :local_build                   => '/var/tmp/file.tar.gz'
      @git_dir_mock   = double "git directory mock"
    end

    context 'when successful' do
      before do
        Heirloom::Directory.should_receive(:new).
                            with(:path    => 'path_to_build',
                                 :exclude => ['.dir_to_exclude'],
                                 :config  => @config_mock).
                            and_return @directory_stub
        Heirloom::GitDirectory.should_receive(:new).
                               with(:path => 'path_to_build').
                               and_return @git_dir_mock
        @builder.should_receive(:create_artifact_record)
      end

      it "should build an archive" do
        git_commit_stub = stub :id_abbrev => 'abc123',
                               :message   => 'yoyo',
                               :author    => @author_stub
        @git_dir_mock.should_receive(:commit).
                      with('123').and_return git_commit_stub
        commit_attributes = { 'sha'             => '123',
                              'abbreviated_sha' => 'abc123',
                              'message'         => 'yoyo',
                              'author'          => 'weaver' }
        @simpledb_mock.should_receive(:put_attributes).
                       with('heirloom_tim', '123', commit_attributes)

        @builder.build(:exclude   => ['.dir_to_exclude'],
                       :directory => 'path_to_build',
                       :git       => 'true').should == '/var/tmp/file.tar.gz'
      end

      it "should build an archive and log a warning if the git sha is not found" do
        @logger_stub.should_receive(:warn).with "Could not find Git sha: 123."
        @git_dir_mock.should_receive(:commit).
                      with('123').and_return false
        @builder.build(:exclude   => ['.dir_to_exclude'],
                       :directory => 'path_to_build',
                       :git       => 'true').should == '/var/tmp/file.tar.gz'
      end

    end

    it "should return false if the build fails" do
      directory_stub = stub :build_artifact_from_directory => false
      Heirloom::Directory.should_receive(:new).with(:path    => 'path_to_build',
                                                    :exclude => ['.dir_to_exclude'],
                                                    :config  => @config_mock).
                                               and_return directory_stub
      @builder.build(:exclude   => ['.dir_to_exclude'],
                     :directory => 'path_to_build',
                     :git       => 'true').should be_false
    end

  end

  describe 'cleanup' do
    it "should cleanup the local archive" do
      @builder.local_build = '/tmp/file'
      File.should_receive(:delete).with('/tmp/file')
      @builder.cleanup
    end
  end

end
