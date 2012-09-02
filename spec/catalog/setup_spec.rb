require 'spec_helper'

describe Heirloom::Catalog::Setup do

  before do
    @logger_stub = stub 'logger', :info => true
    @config_stub = stub 'config', :logger          => @logger_stub,
                                  :metadata_region => 'us-west-1'
    @verify_mock = mock 'verify'
    Heirloom::Catalog::Verify.should_receive(:new).
                              with(:config => @config_stub).
                              and_return @verify_mock
    @setup = Heirloom::Catalog::Setup.new :config => @config_stub,
                                          :name   => 'new_archive'
  end

  it "should call sdb to create the catalog domain" do
    @verify_mock.should_receive(:catalog_domain_exists?).
                 and_return false
    @sdb_mock = mock 'sdb'
    Heirloom::AWS::SimpleDB.should_receive(:new).
                            with(:config => @config_stub).
                            and_return @sdb_mock
    @sdb_mock.should_receive(:create_domain).
              with 'heirloom'
    @setup.create_catalog_domain
  end

end
