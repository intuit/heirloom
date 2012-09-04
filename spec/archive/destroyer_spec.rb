require 'spec_helper'

describe Heirloom do

    before do
      @config_mock = double 'config'
      @logger_stub = stub 'logger', :info => true, :debug => true
      @config_mock.stub :logger => @logger_stub
      @destroyer = Heirloom::Destroyer.new :config => @config_mock,
                                           :name   => 'tim',
                                           :id     => '123'
    end

    before do
      @reader_mock = mock 'archive reader'
      @destroyer.stub :reader => @reader_mock
      @reader_mock.should_receive(:get_bucket).
                  with(:region => 'us-west-1').
                  and_return 'bucket-us-west-1'


      @s3_destroyer_mock = mock 's3 destroyer'
      Heirloom::Destroyer::S3.should_receive(:new).
                              with(:config => @config_mock,
                                   :region => 'us-west-1').
                              and_return @s3_destroyer_mock
      @s3_destroyer_mock.should_receive(:destroy_file).
                        with :key_name   => '123.tar.gz',
                             :key_folder => 'tim',
                             :bucket     => 'bucket-us-west-1'
      @sdb_mock = mock 'sdb'
      @destroyer.stub :sdb => @sdb_mock
    end

    it "should destroy the given archive" do
      @sdb_mock.should_receive(:delete).with 'heirloom_tim', '123'
      @destroyer.destroy :regions => ['us-west-1']
    end

end
