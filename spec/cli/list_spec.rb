require 'spec_helper'
require 'heirloom/cli'

describe Heirloom do

  before do
    options = { :name  => 'archive_name',
                :level => 'info',
                :count => 100 }
    @logger_stub = stub :debug => true
    @config_mock = mock 'config'
    @archive_mock = mock 'archive'
    Trollop.stub(:options).and_return options
    Heirloom::HeirloomLogger.should_receive(:new).with(:log_level => 'info').
                             and_return @logger_stub
    Heirloom::CLI::List.any_instance.should_receive(:load_config).
                        with(:logger => @logger_stub,
                             :opts   => options).
                        and_return @config_mock
    Heirloom::Archive.should_receive(:new).
                      with(:name   => 'archive_name',
                           :config => @config_mock).
                      and_return @archive_mock
    @archive_mock.should_receive(:count)
    @cli_list = Heirloom::CLI::List.new
  end

  it "should list ids for given archive" do
    @archive_mock.should_receive(:list).with(100).and_return(['1','2'])
    JSON.should_receive(:pretty_generate).with ['1','2'], 
                                               { :allow_nan   => true, 
                                                 :max_nesting => false }
    @cli_list.list
  end

end
