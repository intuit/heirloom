require 'spec_helper'

describe Heirloom do

  before do
    @config_mock = double 'config'
    @logger_mock = double 'logger'
    @s3_mock = double 's3_mock'
    @config_mock.should_receive(:logger).and_return(@logger_mock)
    @verifier = Heirloom::Verifier.new :config => @config_mock,
                                       :name   => 'heirloom-name'
  end

  it "should return false if a bucket does not exist" do
    Heirloom::AWS::S3.should_receive(:new).
                      with(:config => @config_mock,
                           :region => 'us-west-1').
                      and_return @s3_mock
    @s3_mock.should_receive(:get_bucket).with('bucket123-us-west-1').
             and_return nil
    @logger_mock.should_receive(:debug)
    @verifier.buckets_exist?(:bucket_prefix => 'bucket123',
                             :regions       => ['us-west-1']).should be_false
  end

  it "should true if all buckets exist" do
    Heirloom::AWS::S3.should_receive(:new).
                      with(:config => @config_mock,
                           :region => 'us-west-1').
                      and_return @s3_mock
    @s3_mock.should_receive(:get_bucket).with('bucket123-us-west-1').
             and_return 'an s3 bucket'
    @logger_mock.should_receive(:debug)
    @verifier.buckets_exist?(:bucket_prefix => 'bucket123',
                             :regions       => ['us-west-1']).should be_true
  end

end
