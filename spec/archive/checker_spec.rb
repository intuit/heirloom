require 'spec_helper'

describe Heirloom do

  before do
    @config_double = double 'config'
    @logger_double = double 'logger', :debug => true, 
                                  :info  => true,
                                  :warn  => true
    @config_double.stub :logger => @logger_double
    @checker = Heirloom::Checker.new :config => @config_double
    @regions = ['us-west-1', 'us-west-2']
  end

  it "should return true if all bucket names are available" do
    s3_double = double 's3'
    Heirloom::AWS::S3.should_receive(:new).
                      with(:config => @config_double,
                           :region => 'us-west-1').
                      and_return s3_double
    Heirloom::AWS::S3.should_receive(:new).
                      with(:config => @config_double,
                           :region => 'us-west-2').
                      and_return s3_double
    s3_double.should_receive(:bucket_name_available?).
            with('bp-us-west-1').
            and_return true
    s3_double.should_receive(:bucket_name_available?).
            with('bp-us-west-2').
            and_return true
    @checker.bucket_name_available?(:bucket_prefix => 'bp',
                                    :regions       => @regions).
                                   should be_true
  end

  it "should return false if any buckets are unavailable" do
    s3_double = double 's3'
    Heirloom::AWS::S3.should_receive(:new).
                      with(:config => @config_double,
                           :region => 'us-west-1').
                      and_return s3_double
    Heirloom::AWS::S3.should_receive(:new).
                      with(:config => @config_double,
                           :region => 'us-west-2').
                      and_return s3_double
    s3_double.should_receive(:bucket_name_available?).
            with('bp-us-west-1').
            and_return false
    s3_double.should_receive(:bucket_name_available?).
            with('bp-us-west-2').
            and_return true
    @checker.bucket_name_available?(:bucket_prefix => 'bp',
                                    :regions       => @regions).
                                   should be_false
  end

end
