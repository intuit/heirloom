require 'spec_helper'

describe Heirloom do

  before do
    @config_mock = double 'config'
    @logger_stub = stub 'logger', :debug => true, :info => true
    @s3_mock = double 's3_mock'
    @config_mock.stub :logger => @logger_stub
    @verifier = Heirloom::Verifier.new :config => @config_mock,
                                       :name   => 'heirloom-name'
  end

  context "verifying all buckets exist" do
    before do
      Heirloom::AWS::S3.should_receive(:new).
                        with(:config => @config_mock,
                             :region => 'us-west-1').
                        and_return @s3_mock
      Heirloom::AWS::S3.should_receive(:new).
                        with(:config => @config_mock,
                             :region => 'us-east-1').
                        and_return @s3_mock
    end
    it "should return false if a bucket does not exist in a region" do
      @s3_mock.should_receive(:get_bucket).with('bucket123-us-west-1').
               and_return nil
      @s3_mock.should_receive(:get_bucket).with('bucket123-us-east-1').
               and_return 'an s3 bucket'
      @verifier.buckets_exist?(:bucket_prefix => 'bucket123',
                               :regions       => ['us-west-1', 'us-east-1']).
                should be_false
    end

    it "should true if all buckets exist" do
      @s3_mock.should_receive(:get_bucket).with('bucket123-us-west-1').
               and_return 'an s3 bucket'
      @s3_mock.should_receive(:get_bucket).with('bucket123-us-east-1').
               and_return 'an s3 bucket'
      @verifier.buckets_exist?(:bucket_prefix => 'bucket123',
                               :regions       => ['us-west-1', 'us-east-1']).
                should be_true
    end
  end

  context "verifying a single bucket exist" do
    it "should return true if the given bucket does not exist in the region" do
      Heirloom::AWS::S3.should_receive(:new).
                        with(:config => @config_mock,
                             :region => 'us-west-1').
                        and_return @s3_mock
      @s3_mock.should_receive(:get_bucket).with('bucket123-us-west-1').
               and_return 'an s3 bucket'
      @verifier.bucket_exists?(:bucket_prefix => 'bucket123',
                               :region        => 'us-west-1').should be_true
    end

    it "should return false if the given bucket does not exist in the region" do
      Heirloom::AWS::S3.should_receive(:new).
                        with(:config => @config_mock,
                             :region => 'us-west-1').
                        and_return @s3_mock
      @s3_mock.should_receive(:get_bucket).with('bucket123-us-west-1').
               and_return 'an s3 bucket'
      @verifier.bucket_exists?(:bucket_prefix => 'bucket123',
                               :region        => 'us-west-1').should be_true
    end
  end

end
