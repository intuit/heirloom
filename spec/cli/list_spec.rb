require 'spec_helper'
require 'heirloom/cli'

describe Heirloom do

  before do
    @options = { :name            => 'archive_name',
                 :level           => 'info',
                 :metadata_region => 'us-west-1',
                 :count           => 100 }
    @logger_double = double :debug => true
    @config_double = double_config :logger => @logger_double
    @archive_double = double 'archive'
    Heirloom::HeirloomLogger.should_receive(:new).with(:log_level => 'info').
                             and_return @logger_double
    Heirloom::CLI::List.any_instance.should_receive(:load_config).
                        with(:logger => @logger_double,
                             :opts   => @options).
                        and_return @config_double
    Heirloom::Archive.should_receive(:new).
                      with(:name => 'archive_name',
                           :config => @config_double).
                      and_return @archive_double
    Heirloom::Archive.should_receive(:new).
                      with(:name   => 'archive_name',
                           :config => @config_double).
                      and_return @archive_double
    @archive_double.should_receive(:domain_exists?).and_return true
    @archive_double.should_receive(:count)
  end

  context "as human readable" do
    before do
      @options[:json] = nil
      Trollop.stub :options => @options
    end

    it "should list ids for given archive" do
      @cli_list = Heirloom::CLI::List.new
      @archive_double.should_receive(:list).with(100).and_return(['1','2'])
      @cli_list.should_receive(:puts).with "1\n2"
      @cli_list.list
    end
  end

end
