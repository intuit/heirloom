require 'spec_helper'

describe Heirloom do

    before do
      @config_mock = double 'config'
      @logger_mock = double 'logger'
      @config_mock.should_receive(:logger).and_return(@logger_mock)
      @destroyer = Heirloom::Destroyer.new :config => @config_mock,
                                                   :name   => 'tim',
                                                   :id     => '123'
    end

    it "should destroy the given archive" do
      @logger_mock.should_receive(:info).
                   with "Destroying tim - 123"
      reader_mock = mock 'archive reader'
      @destroyer.should_receive(:reader).and_return reader_mock
      bucket_mock = mock 'bucket'
      reader_mock.should_receive(:get_bucket).
                  with(:region => 'us-west-1').
                  and_return 'bucket-us-west-1'

      @logger_mock.should_receive(:info).
                   with "Destroying 's3://bucket-us-west-1/tim/123.tar.gz'."

      s3_destroyer_mock = mock 's3 destroyer'
      Heirloom::Destroyer::S3.should_receive(:new).
                              with(:config => @config_mock,
                                   :region => 'us-west-1').
                              and_return s3_destroyer_mock
      s3_destroyer_mock.should_receive(:destroy_file).
                        with :key_name   => '123.tar.gz',
                             :key_folder => 'tim',
                             :bucket     => 'bucket-us-west-1'
      sdb_mock = mock 'sdb'
      @destroyer.should_receive(:sdb).and_return sdb_mock
      sdb_mock.should_receive(:delete).with 'tim', '123'
      @logger_mock.should_receive(:info).
                   with "Destroy complete."
      @destroyer.destroy :regions => ['us-west-1']
    end

end
