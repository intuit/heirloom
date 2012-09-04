require 'spec_helper'
require 'heirloom/cli'

describe Heirloom do

  before do
    options = { :level           => 'info',
                :metadata_region => 'us-west-1',
                :details         => true }
    @result = { 'heirloom_test' => 
                { 'regions' => ['us-west-1'],
                  'base'    => ['base'] } }
    @logger_stub = stub :debug => true
    @config_mock = mock 'config'
    @catalog_mock = mock 'catalog'
    @catalog_mock.stub :catalog_domain_exists? => true
    @config_mock.stub :logger          => @logger_mock, 
                      :access_key      => 'key',
                      :secret_key      => 'secret',
                      :metadata_region => 'us-west-1'
    Trollop.stub(:options).and_return options
    Heirloom::HeirloomLogger.should_receive(:new).with(:log_level => 'info').
                             and_return @logger_stub
    Heirloom::CLI::Catalog.any_instance.should_receive(:load_config).
                           with(:logger => @logger_stub,
                                :opts   => options).
                           and_return @config_mock
    Heirloom::Catalog.should_receive(:new).
                      with(:config => @config_mock).
                      and_return @catalog_mock
    @cli_catalog = Heirloom::CLI::Catalog.new
  end

  it "should list the details about all heirlooms in the catalog" do
    @catalog_mock.should_receive(:all).and_return @result
    formated_result = { 'test' => 
                        { 'regions' => ['us-west-1'],
                          'base'    => ['base'] } }
    @cli_catalog.should_receive(:jj).with formated_result
    @cli_catalog.all
  end

end
