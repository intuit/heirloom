require 'spec_helper'

describe Heirloom::Catalog::Add do

  before do
    @regions     = ['us-west-1', 'us-west-2']
    @base        = 'base'
    @logger_stub = stub 'logger', :info => true
    @config_stub = stub 'config', :logger => @logger_stub
    @add = Heirloom::Catalog::Add.new :config => @config_stub,
                                      :name   => 'new_archive'
  end

  it "should call sdb to add the entry to the catalog" do
    @sdb_mock = mock 'sdb'
    Heirloom::AWS::SimpleDB.should_receive(:new).
                            with(:config => @config_stub).
                            and_return @sdb_mock
    @sdb_mock.should_receive(:put_attributes).
              with 'heirloom',
                   'heirloom_new_archive',
                   "regions" => @regions, "base" => @base
    @add.add_to_catalog :regions => @regions,
                        :base    => @base
  end

end
