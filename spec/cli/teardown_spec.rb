require 'spec_helper'
require 'heirloom/cli'

describe Heirloom do

  before do
    options = { :level           => 'info',
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
    @catalog_mock.stub :regions => ['us-west-1', 'us-west-2']
    @catalog_mock.stub :base => 'base'
    Trollop.stub(:options).and_return options
    Heirloom::HeirloomLogger.should_receive(:new).with(:log_level => 'info').
                             and_return @logger_stub
    Heirloom::CLI::Teardown.any_instance.should_receive(:load_config).
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
    @teardown = Heirloom::CLI::Teardown.new
  end

  it "should delete s3 buckets, catalog and simpledb domain" do
    @teardown.should_receive(:ensure_domain_exists).
              with(:name   => 'archive_name',
                   :config => @config_mock)
    @teardown.should_receive(:ensure_archive_domain_empty).
              with(:archive => @archive_mock,
                   :config  => @config_mock)
    @archive_mock.should_receive(:delete_buckets)
    @archive_mock.should_receive(:delete_domain)
    @catalog_mock.should_receive(:delete_from_catalog)
    @teardown.teardown 
  end

end
