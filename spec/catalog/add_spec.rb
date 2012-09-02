require 'spec_helper'

describe Heirloom::Catalog::Add do

  before do
    @regions     = ['us-west-1', 'us-west-2']
    @base        = 'base'
    @logger_stub = stub 'logger', :info => true
    @config_stub = stub 'config', :logger => @logger_stub
    @verify_mock = mock 'verify'
    Heirloom::Catalog::Verify.should_receive(:new).
                              with(:config => @config_stub).
                              and_return @verify_mock
    @add         = Heirloom::Catalog::Add.new :config => @config_stub,
                                              :name   => 'new_archive'
  end

  it "should call sdb to add the entry to the catalog" do
    @verify_mock.should_receive(:entry_exists_in_catalog?).
                 and_return false
    @sdb_mock = mock 'sdb'
    Heirloom::AWS::SimpleDB.should_receive(:new).
                            with(:config => @config_stub).
                            and_return @sdb_mock
    @sdb_mock.should_receive(:put_attributes).
              with 'heirloom',
                   'heirloom_new_archive',
                   { "regions" => @regions,
                     "base"    => @base }
    @add.add_to_catalog :regions => @regions,
                        :base    => @base
  end

  it "should return false if the entry already exists" do
    @verify_mock.should_receive(:entry_exists_in_catalog?).
                 and_return true
    @add.add_to_catalog(:regions => @regions,
                        :base    => @base).should be_false
  end

end
