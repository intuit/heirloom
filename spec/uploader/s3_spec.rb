require 'spec_helper'

describe Heirloom::Uploader::S3 do
  before do
    @logger_stub = stub 'logger stub', :info  => true,
                                       :warn  => true,
                                       :debug => true
    @config_stub = stub 'config stub', :logger => @logger_stub
    @s3 = Heirloom::Uploader::S3.new :config => @config_stub,
                                     :logger => @logger_stub,
                                     :region => 'us-west-1'
  end

  it "should upload the file to s3" do
    @options = { :bucket          => 'bucket',
                 :file            => 'file',
                 :id              => 'id',
                 :key_name        => 'key_name',
                 :key_folder      => 'key_folder',
                 :name            => 'name',
                 :public_readable => true }
    @s3_double     = double 's3 mock'
    @bucket_double = double 'bucket mock'
    @files_double  = double 'files mock'
    @file_double   = double 'file mock'
    @body_double   = double 'body mock'
    Heirloom::AWS::S3.should_receive(:new).
                      with(:config => @config_stub,
                           :region => 'us-west-1').
                      and_return @s3_double
    @s3_double.should_receive(:get_bucket).
             with('bucket').
             and_return @bucket_double
    @bucket_double.should_receive(:files).and_return(@files_double)
    File.should_receive(:open).with('file').and_return @body_double
    @files_double.should_receive(:create).
                with :key    => "key_folder/key_name",
                     :body   => @body_double,
                     :public => true
    @body_double.should_receive(:close)
    @s3.upload_file @options
  end

  it "should add endpoint attributes for the file to simpledb" do
    simpledb_double = double 'simpledb mock'
    options = { :bucket          => 'bucket',
                :id              => 'id',
                :key_name        => 'key_name',
                :name            => 'name' }
    Heirloom::AWS::SimpleDB.should_receive(:new).
                            with(:config => @config_stub).
                            and_return simpledb_double
    simpledb_double.should_receive(:put_attributes).
                  with("heirloom_name", "id", 
                       { "us-west-1-s3-url" => "s3://bucket/name/key_name" } )
    simpledb_double.should_receive(:put_attributes).
                  with("heirloom_name", "id", 
                       { "us-west-1-http-url" => "http://s3-us-west-1.amazonaws.com/bucket/name/key_name" } )
    simpledb_double.should_receive(:put_attributes).
                  with("heirloom_name", "id", 
                       { "us-west-1-https-url" => "https://s3-us-west-1.amazonaws.com/bucket/name/key_name" } )
    @s3.add_endpoint_attributes options
  end
end
