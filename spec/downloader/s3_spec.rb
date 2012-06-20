require 'spec_helper'

describe Heirloom do

    before do
      @config_mock = double 'config'
      @logger_mock = double 'logger'
      @config_mock.should_receive(:logger).and_return(@logger_mock)

      @s3 = Heirloom::Downloader::S3.new :config  => @config_mock,
                                         :region  => 'us-west-1'
    end

    it "should download the specified file from s3" do
      s3_mock = mock 's3 mock'
      @s3.should_receive(:s3).and_return(s3_mock)
      s3_mock.should_receive(:get_object).
              with 'bucket', 'key_name'
      @s3.download_file :key   => 'key_name',
                        :bucket     => 'bucket'
    end

end
