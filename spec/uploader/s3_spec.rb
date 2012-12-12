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
    @s3_mock     = mock 's3 mock'
    @bucket_mock = mock 'bucket mock'
    @files_mock  = mock 'files mock'
    @file_mock   = mock 'file mock'
    Heirloom::AWS::S3.should_receive(:new).
                      with(:config => @config_stub,
                           :region => 'us-west-1').
                      and_return @s3_mock
    @s3_mock.should_receive(:get_bucket).
             with('bucket').
             and_return @bucket_mock
    @bucket_mock.should_receive(:files).and_return(@files_mock)
    File.should_receive(:open).with('file').and_return "body"
    @files_mock.should_receive(:create).
                with :key    => "key_folder/key_name",
                     :body   => "body",
                     :public => true
    @s3.upload_file @options
  end

  it "should add endpoint attributes for the file to simpledb" do
    simpledb_mock = mock 'simpledb mock'
    options = { :bucket          => 'bucket',
                :id              => 'id',
                :key_name        => 'key_name',
                :name            => 'name' }
    Heirloom::AWS::SimpleDB.should_receive(:new).
                            with(:config => @config_stub).
                            and_return simpledb_mock
    simpledb_mock.should_receive(:put_attributes).
                  with("heirloom_name", "id", 
                       { "us-west-1-s3-url" => "s3://bucket/name/key_name" } )
    simpledb_mock.should_receive(:put_attributes).
                  with("heirloom_name", "id", 
                       { "us-west-1-http-url" => "http://s3-us-west-1.amazonaws.com/bucket/name/key_name" } )
    simpledb_mock.should_receive(:put_attributes).
                  with("heirloom_name", "id", 
                       { "us-west-1-https-url" => "https://s3-us-west-1.amazonaws.com/bucket/name/key_name" } )
    @s3.add_endpoint_attributes options
  end
end
