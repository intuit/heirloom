require 'spec_helper'

describe Heirloom::Builder do
  before do
    @config_mock   = double 'config'
    @logger_stub   = stub :debug => 'true', :info => 'true', :warn => 'true'
    @config_mock.stub(:logger).and_return(@logger_stub)
    @simpledb_mock = double 'simple db'
    @builder       = Heirloom::Builder.new :config => @config_mock,
                                           :name   => 'tim',
                                           :id     => '123'
  end

  describe 'build' do
    context 'when successful' do
      before do
          @author_stub    = stub :name => 'weaver'
          @directory_stub = stub :build_artifact_from_directory => '/tmp/build_dir',
                                 :local_build                   => '/var/tmp/file.tar.gz'

          Heirloom::Directory.should_receive(:new).
                              with(:path    => 'path_to_build',
                                   :exclude => ['.dir_to_exclude'],
                                   :file    => '/tmp/file.tar.gz',
                                   :config  => @config_mock).
                              and_return @directory_stub
          @builder.should_receive(:create_artifact_record)
      end

    end

    it "should return false if the build fails" do
      directory_stub = stub :build_artifact_from_directory => false
      Heirloom::Directory.should_receive(:new).with(:path    => 'path_to_build',
                                                    :exclude => ['.dir_to_exclude'],
                                                    :file    => '/tmp/file.tar.gz',
                                                    :config  => @config_mock).
                                               and_return directory_stub
      @builder.build(:exclude   => ['.dir_to_exclude'],
                     :directory => 'path_to_build',
                     :file      => '/tmp/file.tar.gz').should be_false
    end

  end

end
