require 'spec_helper'

describe Heirloom do

  before do
    @config_mock = mock 'config'
    @logger_stub = mock 'logger', :info => true, :debug => true
    @config_mock.stub :logger => @logger_stub
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
                       and_return 'filedata'
    @file_mock = mock 'file'
  end

  context "extract set to false" do
    context "no secret given" do
      it "should download to the current path if output is not specified" do
        File.should_receive(:open).with('./123.tar.gz', 'w').
                                   and_return @file_mock

        @downloader.download :region      => 'us-west-1',
                             :base_prefix => 'bucket',
                             :extract     => false
      end

      it "should download arhcive to specified output" do
        File.should_receive(:open).with('/tmp/dir/123.tar.gz', 'w').
                                   and_return @file_mock

        @downloader.download :output      => '/tmp/dir',
                             :region      => 'us-west-1',
                             :base_prefix => 'bucket',
                             :extract     => false
      end
    end
  end

  context "extract set to true" do
    before do
      @extracter_mock = mock 'extracter'
      Heirloom::Extracter.should_receive(:new).with(:config => @config_mock).
                          and_return @extracter_mock
    end

    it "should download and extract the to specified output" do
      @extracter_mock.should_receive(:extract).with :archive => 'filedata',
                                                    :output  => '/tmp/dir'
      @downloader.download :output      => '/tmp/dir',
                           :region      => 'us-west-1',
                           :base_prefix => 'bucket',
                           :extract     => true
    end

    it "should download and extract the to the cwd" do
      @extracter_mock.should_receive(:extract).with :archive => 'filedata',
                                                    :output  => './'
      @downloader.download :region      => 'us-west-1',
                           :base_prefix => 'bucket',
                           :extract     => true
    end
  end

  context "secret given" do
    before do
      @cipher_mock = mock 'cipher'
      Heirloom::Cipher.should_receive(:new).
                       with(:config => @config_mock).
                       and_return @cipher_mock
    end

    it "should decrypt the downloaded file with secret" do
      @cipher_mock.should_receive(:decrypt_data).
                   with(:secret => 'supersecret',
                        :data   => 'filedata')
      @downloader.download :region      => 'us-west-1',
                           :base_prefix => 'bucket',
                           :extract     => false,
                           :secret      => 'supersecret'
    end
  end

end
