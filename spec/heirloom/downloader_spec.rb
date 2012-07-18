require 'spec_helper'

describe Heirloom do

    before do
      @config_mock = double 'config'
      @logger_mock = double 'logger'
      @config_mock.should_receive(:logger).and_return(@logger_mock)
      @downloader = Heirloom::Downloader.new :config => @config_mock,
                                                     :name   => 'tim',
                                                     :id     => '123'
    end

    it "should download an archive" do
      s3_downloader_mock = mock 's3 downloader'
      Heirloom::Downloader::S3.should_receive(:new).
                               with(:config => @config_mock,
                                    :logger => @logger_mock,
                                    :region => 'us-west-1').
                               and_return s3_downloader_mock
      reader_mock = mock 'reader'
      @downloader.should_receive(:reader).
                  exactly(2).times.
                  and_return reader_mock
      reader_mock.should_receive(:get_bucket).
                           with(:region => 'us-west-1').
                           and_return 'bucket-us-west-1'
      reader_mock.should_receive(:get_key).
                           with(:region => 'us-west-1').
                           and_return 'key'

      @logger_mock.should_receive(:info).
                   with "Downloading s3://bucket-us-west-1/key from us-west-1."

      s3_downloader_mock.should_receive(:download_file).
                         with(:bucket => 'bucket-us-west-1',
                              :key    => 'key').
                         and_return 'filename'

      @logger_mock.should_receive(:info).
                   with "Writing file to /tmp/file."

      file_mock = mock 'file'

      File.should_receive(:open).with('/tmp/file', 'w').
                                 and_return file_mock

      @logger_mock.should_receive(:info).with "Download complete."

      @downloader.download(:output => '/tmp/file',
                           :region => 'us-west-1')
    end

    it "should download the archive to the current path if output is unspecficief" do
      s3_downloader_mock = mock 's3 downloader'
      Heirloom::Downloader::S3.should_receive(:new).
                               with(:config => @config_mock,
                                    :logger => @logger_mock,
                                    :region => 'us-west-1').
                               and_return s3_downloader_mock
      reader_mock = mock 'reader'
      @downloader.should_receive(:reader).
                  exactly(2).times.
                  and_return reader_mock
      reader_mock.should_receive(:get_bucket).
                  with(:region => 'us-west-1').
                  and_return 'bucket-us-west-1'
      reader_mock.should_receive(:get_key).
                  with(:region => 'us-west-1').
                  and_return 'key'

      @logger_mock.should_receive(:info).
                   with "Downloading s3://bucket-us-west-1/key from us-west-1."

      s3_downloader_mock.should_receive(:download_file).
                         with(:bucket => 'bucket-us-west-1',
                              :key    => 'key').
                         and_return 'filename'

      @logger_mock.should_receive(:info).
                   with "Writing file to ./key."

      file_mock = mock 'file'

      File.should_receive(:open).with('./key', 'w').
                                 and_return file_mock

      @logger_mock.should_receive(:info).with "Download complete."

      @downloader.download(:region => 'us-west-1')
    end

end
