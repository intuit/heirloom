require 'spec_helper'

describe Heirloom do

  before do
    @config_double = double 'config'
    @logger_double = double 'logger', :info => true, :debug => true
    @config_double.stub :logger => @logger_double
    @downloader = Heirloom::Downloader.new :config => @config_double,
                                           :name   => 'tim',
                                           :id     => '123'
    @s3_downloader_double = double 's3 downloader'
    Heirloom::Downloader::S3.should_receive(:new).
                             with(:config => @config_double,
                                  :logger => @logger_double,
                                  :region => 'us-west-1').
                             and_return @s3_downloader_double
    @cipher_double = double 'cipher'
  end

  context "no secret given" do
    context "when succesful" do
      before do
        @writer_double = double 'writer'
        Heirloom::Writer.should_receive(:new).
                         with(:config => @config_double).
                         and_return @writer_double
        @s3_downloader_double.should_receive(:download_file).
                            with(:bucket => 'bucket-us-west-1',
                                 :key    => 'tim/123.tar.gz').
                            and_return 'plaintext'
        @cipher_double.should_receive(:decrypt_data).
                     with(:secret => nil,
                          :data   => 'plaintext').and_return 'plaintext'
        Heirloom::Cipher::Data.should_receive(:new).
                               with(:config => @config_double).
                               and_return @cipher_double
      end

      it "should download to the current path if output is not specified" do
        @writer_double.should_receive(:save_archive).
                     with(:archive => 'plaintext',
                          :file    => "123.tar.gz",
                          :output  => './',
                          :extract => false).and_return true
        @downloader.download(:region        => 'us-west-1',
                             :bucket_prefix => 'bucket',
                             :extract       => false,
                             :secret        => nil).should == './'
      end

      it "should download arhcive to specified output" do
        @writer_double.should_receive(:save_archive).
                     with(:archive => 'plaintext',
                          :file    => "123.tar.gz",
                          :output  => '/tmp/dir',
                          :extract => false).and_return true
        @downloader.download(:output        => '/tmp/dir',
                             :region        => 'us-west-1',
                             :bucket_prefix => 'bucket',
                             :extract       => false,
                             :secret        => nil).should == '/tmp/dir'
      end
    end

    context "when unsuccesful" do
      before do
        @s3_downloader_double.should_receive(:download_file).
                            with(:bucket => 'bucket-us-west-1',
                                 :key    => 'tim/123.tar.gz').
                            and_return false
      end

      it "should return false if the archive is not downloaded" do
        @downloader.download(:output        => '/tmp/dir',
                             :region        => 'us-west-1',
                             :bucket_prefix => 'bucket',
                             :extract       => false,
                             :secret        => nil).should be_false
      end
    end
  end

  context "secret given" do
    before do
      @s3_downloader_double.should_receive(:download_file).
                          with(:bucket => 'bucket-us-west-1',
                               :key    => 'tim/123.tar.gz.gpg').
                          and_return 'encrypted_data'
      Heirloom::Cipher::Data.should_receive(:new).
                             with(:config => @config_double).
                             and_return @cipher_double
    end

    context "valid secret" do
      before do
        @writer_double = double 'writer'
        Heirloom::Writer.should_receive(:new).
                         with(:config => @config_double).
                         and_return @writer_double
        @cipher_double.should_receive(:decrypt_data).
                     with(:secret => 'supersecret',
                          :data   => 'encrypted_data').and_return 'plaintext'
      end

      it "should decrypt and save the downloaded file with secret" do
        @writer_double.should_receive(:save_archive).
                     with(:archive => 'plaintext',
                          :file    => "123.tar.gz",
                          :output  => './',
                          :extract => false).and_return true
        @downloader.download :region        => 'us-west-1',
                             :bucket_prefix => 'bucket',
                             :extract       => false,
                             :secret        => 'supersecret'
      end

      it "should decrypt and extract the downloaded file with secret" do
        @writer_double.should_receive(:save_archive).
                     with(:archive => 'plaintext',
                          :file    => "123.tar.gz",
                          :output  => './',
                          :extract => true).and_return true
        @downloader.download :region      => 'us-west-1',
                             :bucket_prefix => 'bucket',
                             :extract     => true,
                             :secret      => 'supersecret'
      end
    end

    context "invalid secret" do
      before do
        @cipher_double.should_receive(:decrypt_data).
                     with(:secret => 'badsecret',
                          :data   => 'encrypted_data').and_return false
      end

      it "should return false if the decrypt_data returns false" do
        @downloader.download(:region        => 'us-west-1',
                             :bucket_prefix => 'bucket',
                             :extract       => false,
                             :secret        => 'badsecret').should be_false
      end 

    end
  end
end
