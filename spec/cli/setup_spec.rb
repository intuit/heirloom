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

    @logger_stub = double 'logger', :error => true, :info => true
    @config_double = double_config :logger => @logger_stub
    @archive_double = double 'archive'
    @catalog_double = double 'catalog'
    @checker_double = double 'checker'
    Trollop.stub(:options).and_return options
    Heirloom::HeirloomLogger.should_receive(:new).with(:log_level => 'info').
                             and_return @logger_stub
    Heirloom::CLI::Setup.any_instance.should_receive(:load_config).
                         with(:logger => @logger_stub,
                               :opts   => options).
                          and_return @config_double
    Heirloom::Archive.should_receive(:new).
                      with(:name => 'archive_name',
                           :config => @config_double).
                      and_return @archive_double
    Heirloom::Catalog.should_receive(:new).
                      with(:name => 'archive_name',
                           :config => @config_double).
                      and_return @catalog_double
    Heirloom::Checker.should_receive(:new).
                      with(:config => @config_double).
                      and_return @checker_double
    @setup = Heirloom::CLI::Setup.new
  end

  it "should setup s3 buckets, catalog and simpledb domain" do
    @checker_double.should_receive(:bucket_name_available?).
                  with(:bucket_prefix => "bp", 
                       :regions       => @regions, 
                       :config        => @config_double).
                  and_return true
    @catalog_double.should_receive(:create_catalog_domain)
    @catalog_double.stub :entry_exists_in_catalog? => false
    @catalog_double.should_receive(:add_to_catalog).
                  with(:regions       => @regions, 
                       :bucket_prefix => 'bp').
                  and_return true
    @archive_double.should_receive(:setup).
                  with(:regions       => @regions,
                       :bucket_prefix => 'bp')
    @setup.setup 
  end

end
