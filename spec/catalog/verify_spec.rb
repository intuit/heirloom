require 'spec_helper'

describe Heirloom::Catalog::Verify do

  before do
    @sdb_mock    = mock 'sdb'
    @logger_stub = stub 'logger', :info => true,
                                  :debug => true
    @config_stub = stub 'config', :logger          => @logger_stub,
                                  :metadata_region => 'us-west-1'
    Heirloom::AWS::SimpleDB.should_receive(:new).
                            with(:config => @config_stub).
                            and_return @sdb_mock
    @verify = Heirloom::Catalog::Verify.new :config => @config_stub,
                                            :name   => 'a_archive'

  end

  context "testing catalog_domain_exists" do
    it "should return true if heirloom domain exists" do
      @sdb_mock.should_receive(:domain_exists?).
                with('heirloom').and_return true
      @verify.catalog_domain_exists?.should be_true
    end

    it "should return false if heirloom domain does not exists" do
      @sdb_mock.should_receive(:domain_exists?).
                with('heirloom').and_return false
      @verify.catalog_domain_exists?.should be_false
    end
  end

  context "testing entry_exists_in_catalog?" do
    it "should return true if an entry exists in catalog" do
      @sdb_mock.should_receive(:item_count).
                with('heirloom', 'heirloom_a_archive').and_return 1
      @verify.entry_exists_in_catalog?('a_archive').should be_true
    end

    it "should return false if an entry does not exist in catalog" do
      @sdb_mock.should_receive(:item_count).
                with('heirloom', 'heirloom_a_archive').and_return 0
      @verify.entry_exists_in_catalog?('a_archive').should be_false
    end
  end

end
