require 'spec_helper'

describe Heirloom do

  before do
    @config_mock = double 'config'
    @logger_stub = stub 'logger', :debug => true, :info => true
    @config_mock.stub :logger => @logger_stub
    @checker = Heirloom::Checker.new :config => @config_mock
    @regions = ['us-west-1', 'us-west-2']
  end

  it "should return true if all bucket names are available" do
    s3_mock = mock 's3'
    Heirloom::AWS::S3.should_receive(:new).
                      with(:config => @config_mock,
                           :region => 'us-west-1').
                      and_return s3_mock
    Heirloom::AWS::S3.should_receive(:new).
                      with(:config => @config_mock,
                           :region => 'us-west-2').
                      and_return s3_mock
    s3_mock.should_receive(:bucket_name_available_in_region?).
            with('bp-us-west-1').
            and_return true
    s3_mock.should_receive(:bucket_name_available_in_region?).
            with('bp-us-west-2').
            and_return true
    @checker.bucket_name_available?(:bucket_prefix => 'bp',
                                    :regions       => @regions).
                                   should be_true
  end

  it "should return false if any buckets are unavailable" do
    s3_mock = mock 's3'
    Heirloom::AWS::S3.should_receive(:new).
                      with(:config => @config_mock,
                           :region => 'us-west-1').
                      and_return s3_mock
    Heirloom::AWS::S3.should_receive(:new).
                      with(:config => @config_mock,
                           :region => 'us-west-2').
                      and_return s3_mock
    s3_mock.should_receive(:bucket_name_available_in_region?).
            with('bp-us-west-1').
            and_return false
    s3_mock.should_receive(:bucket_name_available_in_region?).
            with('bp-us-west-2').
            and_return true
    @checker.bucket_name_available?(:bucket_prefix => 'bp',
                                    :regions       => @regions).
                                   should be_false
  end

end
