require 'spec_helper'
require 'heirloom/cli'

describe Heirloom do

  before do
    @options = { :level           => 'info',
                 :metadata_region => 'us-west-1' }
    @result = { 'heirloom_test' => 
                { 'regions'       => ['us-west-1'],
                  'bucket_prefix' => ['bp'] } }
    @logger_stub = stub :debug => true
    @config_mock = mock_config :logger => @logger_stub
    @catalog_mock = mock 'catalog'
    @catalog_mock.stub :catalog_domain_exists? => true
    Heirloom::HeirloomLogger.should_receive(:new).with(:log_level => 'info').
                             and_return @logger_stub
    Heirloom::CLI::Catalog.any_instance.should_receive(:load_config).
                           with(:logger => @logger_stub,
                                :opts   => @options).
                           and_return @config_mock
    Heirloom::Catalog.should_receive(:new).
                      with(:config => @config_mock).
                      and_return @catalog_mock
  end

  context "as json" do
    before do
      @options[:json] = true
      Trollop.stub :options => @options
    end

    it "should list the details about all heirlooms in the catalog" do
      @cli_catalog = Heirloom::CLI::Catalog.new
      @catalog_mock.stub :all => @result
      formated_result = { 'test' => 
                          { 'regions'       => ['us-west-1'],
                            'bucket_prefix' => ['bp'] } }
      @cli_catalog.should_receive(:jj).with formated_result
      @cli_catalog.all
    end
  end

  context "as human readable" do
    before do
      @options[:json] = nil
      Trollop.stub :options => @options
    end

    it "should list all heirlooms in the catalog" do
      @cli_catalog = Heirloom::CLI::Catalog.new
      @catalog_mock.stub :all => @result
      formatter_mock = mock 'formatter'
      catalog = { :region => "us-west-1",
                  :catalog =>
                  { "  test" =>
                    {
                      "regions"       => ["us-west-1"], 
                      "bucket_prefix" => ["bp"] 
                    }
                  },
                  :name => nil
                }
      Heirloom::CLI::Formatter::Catalog.stub :new => formatter_mock
      formatter_mock.should_receive(:format).with(catalog).and_return 'theoutput'
      @cli_catalog.should_receive(:puts).with 'theoutput'
      @cli_catalog.all
    end
  end

end
