require 'spec_helper'

describe Heirloom do

    before do
      @config_double = double 'config'
      @logger_double = double 'logger', :info => true, :debug => true
      @config_double.stub :logger => @logger_double
      @destroyer = Heirloom::Destroyer.new :config => @config_double,
                                           :name   => 'tim',
                                           :id     => '123'
    end

    before do
      @reader_double = double 'archive reader'
      @destroyer.stub :reader => @reader_double
      @reader_double.should_receive(:get_bucket).
                     with(:region => 'us-west-1').
                     and_return 'bucket-us-west-1'
      @reader_double.stub :key_name => '123.tar.gz'

      @s3_destroyer_double = double 's3 destroyer'
      Heirloom::Destroyer::S3.should_receive(:new).
                              with(:config => @config_double,
                                   :region => 'us-west-1').
                              and_return @s3_destroyer_double
      @s3_destroyer_double.should_receive(:destroy_file).
                           with :key_name   => '123.tar.gz',
                                :key_folder => 'tim',
                                :bucket     => 'bucket-us-west-1'
      @sdb_double = double 'sdb'
      @destroyer.stub :sdb => @sdb_double
    end

    it "should destroy the given archive" do
      @sdb_double.should_receive(:delete).with 'heirloom_tim', '123'
      @destroyer.destroy :regions => ['us-west-1']
    end

end
