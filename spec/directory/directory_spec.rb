require 'spec_helper'

describe Heirloom do

    before do
      @config_mock = double 'config'
      @logger_mock = double 'logger'
      @config_mock.should_receive(:logger).and_return(@logger_mock)
      @directory = Heirloom::Directory.new :config  => @config_mock,
                                           :exclude => ['.', '..', 'pack_me'],
                                           :path    => '/target/dir'
    end

    it "should build an archive from the latest commit in path" do
      @logger_mock.should_receive(:info).exactly(3).times
      file_mock = double 'file'
      File.should_receive(:open).and_return file_mock
      gzip_mock = double 'gzip mock'
      Zlib::GzipWriter.should_receive(:new).and_return gzip_mock
      @directory.should_receive(:files_to_pack).
                 exactly(2).times.and_return(['pack_me'])
      Minitar.should_receive(:pack).with(['pack_me'], gzip_mock)
      @directory.build_artifact_from_directory
    end

end
