require 'spec_helper'

describe Heirloom::Catalog::Verify do

  before do
    @sdb_double    = double 'sdb'
    @logger_double = double 'logger', :info => true,
                                      :debug => true
    @config_double = double 'config', :logger          => @logger_double,
                                      :metadata_region => 'us-west-1'
    Heirloom::AWS::SimpleDB.should_receive(:new).
                            with(:config => @config_double).
                            and_return @sdb_double
    @verify = Heirloom::Catalog::Verify.new :config => @config_double,
                                            :name   => 'a_archive'

  end

  context "testing catalog_domain_exists" do
    it "should return true if heirloom domain exists" do
      @sdb_double.should_receive(:domain_exists?).
                  with('heirloom').and_return true
      @verify.catalog_domain_exists?.should be_true
    end

    it "should return false if heirloom domain does not exists" do
      @sdb_double.should_receive(:domain_exists?).
                  with('heirloom').and_return false
      @verify.catalog_domain_exists?.should be_false
    end
  end

  context "testing entry_exists_in_catalog?" do
    it "should return true if an entry exists in catalog" do
      @sdb_double.should_receive(:item_count).
                  with('heirloom', 'heirloom_a_archive').and_return 1
      @verify.entry_exists_in_catalog?('a_archive').should be_true
    end

    it "should return false if an entry does not exist in catalog" do
      @sdb_double.should_receive(:item_count).
                  with('heirloom', 'heirloom_a_archive').and_return 0
      @verify.entry_exists_in_catalog?('a_archive').should be_false
    end
  end

end
