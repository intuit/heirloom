require 'spec_helper'
require 'heirloom/cli'

describe Heirloom do

  before do
    @options = { :level           => 'info',
                 :metadata_region => 'us-west-1' }

    @result = { 'heirloom_test' =>
                { 'regions'       => ['us-west-1'],
                  'bucket_prefix' => ['bp'] } }
    @logger_double = double :debug => true
    @logger_double.stub :info => true
    @config_double = double_config :logger => @logger_double
    @catalog_double = double 'catalog'
    @catalog_double.stub :catalog_domain_exists? => true
    Heirloom::HeirloomLogger.should_receive(:new).with(:log_level => 'info').
                             and_return @logger_double
    Heirloom::CLI::Catalog.any_instance.should_receive(:load_config).
                           with(:logger => @logger_double,
                                :opts   => @options).
                           and_return @config_double
    Heirloom::Catalog.should_receive(:new).
                      with(:config => @config_double).
                      and_return @catalog_double
  end

  context "as human readable" do
    before do
      Trollop.stub :options => @options
    end

    it "should list all heirlooms in the catalog" do
      @cli_catalog = Heirloom::CLI::Catalog.new
      @catalog_double.stub :all => @result
      formatter_double = double 'formatter'
      catalog = { :region  => "us-west-1",
                  :catalog =>
                  { "heirloom_test" =>
                    {
                      "regions"       => ["us-west-1"], 
                      "bucket_prefix" => ["bp"] 
                    }
                  },
                  :name => nil
                }
      Heirloom::CLI::Formatter::Catalog.stub :new => formatter_double
      formatter_double.should_receive(:summary_format).with(:region=>"us-west-1").and_return('theoutput')
      @cli_catalog.should_receive(:puts).with 'theoutput'
      @cli_catalog.all
    end
  end

end
