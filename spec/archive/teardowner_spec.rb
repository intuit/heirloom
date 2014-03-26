require 'spec_helper'

describe Heirloom::Teardowner do
  before do
    @regions = ['us-west-1', 'us-west-2']
    @logger_stub = double 'logger', :info => true, :debug => true
    @config_stub = double 'config', :logger          => @logger_stub,
                                  :metadata_region => 'us-west-1'
    @verifier_stub = double :bucket_exists? => true,
                          :domain_exists? => true 
    @teardowner = Heirloom::Teardowner.new :config => @config_stub,
                                           :name   => 'archive'
    Heirloom::Verifier.stub :new => @verifier_stub
  end

  it "should delete the buckets" do
    @s3_double1 = double 's31'
    @s3_double2 = double 's32'
    Heirloom::AWS::S3.should_receive(:new).
                      with(:config => @config_stub,
                           :region => 'us-west-1').
                      and_return @s3_double1
    Heirloom::AWS::S3.should_receive(:new).
                      with(:config => @config_stub,
                           :region => 'us-west-2').
                      and_return @s3_double2
    @s3_double1.should_receive(:delete_bucket).with('bp-us-west-1')
    @s3_double2.should_receive(:delete_bucket).with('bp-us-west-2')
    @teardowner.delete_buckets :regions       => @regions,
                               :bucket_prefix => 'bp'
  end

  it "should delete the domain" do
    @sdb_double = double 'sdb'
    Heirloom::AWS::SimpleDB.should_receive(:new).
                            with(:config => @config_stub).
                            and_return @sdb_double
    @sdb_double.should_receive(:delete_domain).
              with 'heirloom_archive'
    @teardowner.delete_domain
  end
end
