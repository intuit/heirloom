require 'spec_helper'

describe Heirloom do

  before do
    @logger_double = double 'logger', :debug => true, :info => true
    @config_double = double 'config'
    @config_double.stub :logger => @logger_double, :metadata_region => 'us-west-1'
    @verifier_double = double 'verifier'
    Heirloom::Verifier.should_receive(:new).
                       with(:config => @config_double,
                            :name   => 'archive').
                       and_return @verifier_double
    @setuper = Heirloom::Setuper.new :config => @config_double,
                                     :name   => 'archive'
  end

  context "creating domains" do
    before do
      @verifier_double.stub :bucket_exists? => true
    end

    it "should create the domain if it does not exist" do
      @sdb_double = double 'sdb'
      Heirloom::AWS::SimpleDB.should_receive(:new).
                              with(:config => @config_double).
                              and_return @sdb_double
      @verifier_double.stub :domain_exists? => false
      @sdb_double.should_receive(:create_domain).with 'heirloom_archive'
      @setuper.setup :regions       => ['us-west-1'],
                     :bucket_prefix => 'bp'
                     
    end

    it "should not create the domain if alrady exists" do
      @verifier_double.stub :domain_exists? => true
      @setuper.setup :regions       => ['us-west-1'],
                     :bucket_prefix => 'bp'
    end
  end

  context "creating buckets" do
    before do
      @verifier_double.stub :domain_exists? => true
    end

    it "should create required buckets that don't exist" do
      @verifier_double.should_receive(:bucket_exists?).
                     with(:region => "us-west-1", :bucket_prefix => "bp").
                     and_return true
      @verifier_double.should_receive(:bucket_exists?).
                     with(:region => "us-east-1", :bucket_prefix => "bp").
                     and_return false
      @s3_double = double 's3'
      Heirloom::AWS::S3.should_receive(:new).
                        with(:config => @config_double,
                             :region => 'us-east-1').
                        and_return @s3_double
      @s3_double.should_receive(:put_bucket).
               with 'bp-us-east-1', 'us-east-1'
      @setuper.setup :regions       => ['us-west-1', 'us-east-1'],
                     :bucket_prefix => 'bp'
    end
  end

end
