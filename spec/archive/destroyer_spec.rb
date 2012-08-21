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

    before do
      @logger_mock.stub :info => true
      @reader_mock = mock 'archive reader'
      @destroyer.should_receive(:reader).and_return @reader_mock
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
      @sdb_mock.should_receive(:delete).with 'heirloom_tim', '123'
    end

    it "should destroy the given archive" do
      Kernel.should_receive(:sleep).with 3
      @sdb_mock.should_receive(:domain_empty?).with('heirloom_tim').
               and_return true
      @sdb_mock.should_receive(:delete_domain).with('heirloom_tim')
      @destroyer.destroy :regions => ['us-west-1'],
                         :keep_domain => false
    end

    it "should destroy the given archive but keep the sbd domain" do
      @sdb_mock.should_receive(:domain_empty?).exactly(0).times
      @sdb_mock.should_receive(:delete_domain).exactly(0).times
      @destroyer.destroy :regions     => ['us-west-1'],
                         :keep_domain => true
    end

end
