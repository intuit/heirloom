require 'spec_helper'

describe Heirloom do

  before do
    @config_mock = double 'config'
    @logger_stub = double 'logger', :info => true, :debug => true
    @config_mock.should_receive(:logger).and_return(@logger_stub)
    @downloader = Heirloom::Downloader.new :config => @config_mock,
                                           :name   => 'tim',
                                           :id     => '123'
    @s3_downloader_mock = mock 's3 downloader'
    Heirloom::Downloader::S3.should_receive(:new).
                             with(:config => @config_mock,
                                  :logger => @logger_stub,
                                  :region => 'us-west-1').
                             and_return @s3_downloader_mock
    @s3_downloader_mock.should_receive(:download_file).
                       with(:bucket => 'bucket-us-west-1',
                            :key    => 'tim/123.tar.gz').
                       and_return 'filename'
    @file_mock = mock 'file'
  end

  context "with base_prefix specified" do
    it "should download to the current path if output is not specified" do
      File.should_receive(:open).with('./123.tar.gz', 'w').
                                 and_return @file_mock

      @downloader.download :region      => 'us-west-1',
                           :base_prefix => 'bucket'
    end

    it "should download arhcive to specified output" do
      File.should_receive(:open).with('/tmp/file', 'w').
                                 and_return @file_mock

      @downloader.download :output      => '/tmp/file',
                           :region      => 'us-west-1',
                           :base_prefix => 'bucket'
    end
  end

end
