require 'spec_helper'

describe Heirloom::Catalog::Add do

  before do
    @regions       = ['us-west-1', 'us-west-2']
    @bucket_prefix = 'bucket_prefix'
    @logger_stub   = stub 'logger', :info => true
    @config_stub   = stub 'config', :logger => @logger_stub
    @verify_stub   = stub 'verify'

    @add = Heirloom::Catalog::Add.new :config => @config_stub,
                                      :name   => 'new_archive'
    Heirloom::Catalog::Verify.should_receive(:new).
                              with(:config => @config_stub).
                              and_return @verify_stub
  end

  it "should call sdb to add the entry to the catalog" do
    @sdb_double = double 'sdb'
    @verify_stub.stub :entry_exists_in_catalog? => false
    Heirloom::AWS::SimpleDB.should_receive(:new).
                            with(:config => @config_stub).
                            and_return @sdb_double
    @sdb_double.should_receive(:put_attributes).
              with 'heirloom',
                   'heirloom_new_archive',
                   "regions" => @regions, "bucket_prefix" => @bucket_prefix
    @add.add_to_catalog :regions       => @regions,
                        :bucket_prefix => @bucket_prefix
  end

  it "should not add the entry to the catalog if it's already there" do
    @verify_stub.stub :entry_exists_in_catalog? => true
    Heirloom::AWS::SimpleDB.should_receive(:new).never
    @add.add_to_catalog :regions       => @regions,
                        :bucket_prefix => @bucket_prefix
  end

end
