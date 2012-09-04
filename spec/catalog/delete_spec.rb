require 'spec_helper'

describe Heirloom::Catalog::Delete do

  before do
    @logger_stub = stub 'logger', :info => true
    @config_stub = stub 'config', :logger => @logger_stub
    @verify_stub = stub 'verify'
    Heirloom::Catalog::Verify.should_receive(:new).
                              with(:config => @config_stub).
                              and_return @verify_stub
    @delete = Heirloom::Catalog::Delete.new :config => @config_stub,
                                            :name   => 'old_archive'
  end

  it "should delete the entry from the catalog" do
    @verify_stub.stub :catalog_domain_exists? => true
    @sdb_mock = mock 'sdb'
    Heirloom::AWS::SimpleDB.should_receive(:new).
                            with(:config => @config_stub).
                            and_return @sdb_mock
    @sdb_mock.should_receive(:delete).
              with('heirloom', 'heirloom_old_archive').
              and_return true
    @delete.delete_from_catalog.should be_true
  end

  it "should return false if an entry does not exist in catalog" do
    @verify_stub.stub :catalog_domain_exists? => false
    @delete.delete_from_catalog.should be_false
  end

end
