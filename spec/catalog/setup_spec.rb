require 'spec_helper'

describe Heirloom::Catalog::Setup do

  before do
    @logger_double = double 'logger', :info => true
    @config_double = double 'config', :logger          => @logger_double,
                                  :metadata_region => 'us-west-1'
    @verify_double = double 'verify', :catalog_domain_exists? => false
    Heirloom::Catalog::Verify.should_receive(:new).
                              with(:config => @config_double).
                              and_return @verify_double
    @setup = Heirloom::Catalog::Setup.new :config => @config_double,
                                          :name   => 'new_archive'
  end

  it "should call sdb to create the catalog domain" do
    @sdb_double = double 'sdb'
    Heirloom::AWS::SimpleDB.should_receive(:new).
                            with(:config => @config_double).
                            and_return @sdb_double
    @sdb_double.should_receive(:create_domain).
              with 'heirloom'
    @setup.create_catalog_domain
  end

end
