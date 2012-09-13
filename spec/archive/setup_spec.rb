require 'spec_helper'

describe Heirloom do

  before do
    @logger_stub = stub 'logger', :debug => true, :info => true
    @config_mock = mock 'config'
    @config_mock.stub :logger => @logger_stub, :metadata_region => 'us-west-1'
    @verifier_mock = mock 'verifier'
    Heirloom::Verifier.should_receive(:new).
                       with(:config => @config_mock,
                            :name   => 'archive').
                       and_return @verifier_mock
    @setuper = Heirloom::Setuper.new :config => @config_mock,
                                     :name   => 'archive'
  end

  context "creating domains" do
    before do
      @verifier_mock.stub :bucket_exists? => true
    end

    it "should create the domain if it does not exist" do
      @sdb_mock = mock 'sdb'
      Heirloom::AWS::SimpleDB.should_receive(:new).
                              with(:config => @config_mock).
                              and_return @sdb_mock
      @verifier_mock.stub :domain_exists? => false
      @sdb_mock.should_receive(:create_domain).with 'heirloom_archive'
      @setuper.setup :regions       => ['us-west-1'],
                     :bucket_prefix => 'bp'
                     
    end

    it "should not create the domain if alrady exists" do
      @verifier_mock.stub :domain_exists? => true
      @setuper.setup :regions       => ['us-west-1'],
                     :bucket_prefix => 'bp'
    end
  end

  context "creating buckets" do
    before do
      @verifier_mock.stub :domain_exists? => true
    end

    it "should create required buckets that don't exist" do
      @verifier_mock.should_receive(:bucket_exists?).
                     with(:region => "us-west-1", :bucket_prefix => "bp").
                     and_return true
      @verifier_mock.should_receive(:bucket_exists?).
                     with(:region => "us-east-1", :bucket_prefix => "bp").
                     and_return false
      @s3_mock = mock 's3'
      Heirloom::AWS::S3.should_receive(:new).
                        with(:config => @config_mock,
                             :region => 'us-east-1').
                        and_return @s3_mock
      @s3_mock.should_receive(:put_bucket).
               with 'bp-us-east-1', 'us-east-1'
      @setuper.setup :regions       => ['us-west-1', 'us-east-1'],
                     :bucket_prefix => 'bp'
    end
  end

end
