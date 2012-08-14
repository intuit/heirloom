require 'spec_helper'
require 'heirloom/cli'

describe Heirloom do

  before do
    options = { :name  => 'archive_name',
                :id    => '1.0.0',
                :level => 'info' }
    @logger_stub = stub :debug => true
    @config_mock = mock 'config'
    @archive_mock = mock 'archive'
    Trollop.stub(:options).and_return options
    Heirloom::HeirloomLogger.should_receive(:new).with(:log_level => 'info').
                             and_return @logger_stub
    Heirloom::CLI::Show.any_instance.should_receive(:load_config).
                        with(:logger => @logger_stub,
                             :opts   => options).
                        and_return @config_mock
    Heirloom::Archive.should_receive(:new).
                      with(:name   => 'archive_name',
                           :id     => '1.0.0',
                           :config => @config_mock).
                      and_return @archive_mock
    @archive_mock.should_receive(:domain_exists?).and_return true
    @cli_show = Heirloom::CLI::Show.new
  end

  it "should show a given id" do
    @archive_mock.should_receive(:show).and_return( { 'id' => '1.0.0' } )
    @cli_show.should_receive(:jj).with 'id' => '1.0.0'
    @cli_show.show
  end

end
