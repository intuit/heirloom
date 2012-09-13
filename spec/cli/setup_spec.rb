require 'spec_helper'
require 'heirloom/cli'

describe Heirloom do

  before do
    @regions = ['us-west-1', 'us-west-2']
    options = { :level           => 'info',
                :bucket_prefix   => 'bp',
                :region          => @regions,
                :name            => 'archive_name',
                :metadata_region => 'us-west-1' }

    @logger_stub = stub 'logger', :error => true, :info => true
    @config_mock = mock 'config'
    @config_mock.stub :logger          => @logger_stub,
                      :access_key      => 'key',
                      :secret_key      => 'secret',
                      :metadata_region => 'us-west-1'
    @archive_mock = mock 'archive'
    @catalog_mock = mock 'catalog'
    Trollop.stub(:options).and_return options
    Heirloom::HeirloomLogger.should_receive(:new).with(:log_level => 'info').
                             and_return @logger_stub
    Heirloom::CLI::Setup.any_instance.should_receive(:load_config).
                         with(:logger => @logger_stub,
                               :opts   => options).
                          and_return @config_mock
    Heirloom::Archive.should_receive(:new).
                      with(:name => 'archive_name',
                           :config => @config_mock).
                      and_return @archive_mock
    Heirloom::Catalog.should_receive(:new).
                      with(:name => 'archive_name',
                           :config => @config_mock).
                      and_return @catalog_mock
    @setup = Heirloom::CLI::Setup.new
  end

  it "should setup s3 buckets, catalog and simpledb domain" do
    @catalog_mock.should_receive(:create_catalog_domain)
    @catalog_mock.stub :entry_exists_in_catalog? => false
    @catalog_mock.should_receive(:add_to_catalog).
                  with(:regions       => @regions, 
                       :bucket_prefix => 'bp').
                  and_return true
    @archive_mock.should_receive(:setup).
                  with(:regions       => @regions,
                       :bucket_prefix => 'bp')
    @setup.setup 
  end

end
