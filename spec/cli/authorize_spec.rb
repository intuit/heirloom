require 'spec_helper'
require 'heirloom/cli'

describe Heirloom do

  before do
    options = { :level    => 'info',
                :accounts => ['test@test.com'],
                :name     => 'archive_name',
                :id       => '1.0.0' }
    @logger_mock = mock 'logger'
    @config_mock = mock 'config'
    @archive_mock = mock 'archive'
    @config_mock.stub :logger => @logger_mock
    Trollop.stub(:options).and_return options
    Heirloom::HeirloomLogger.should_receive(:new).with(:log_level => 'info').
                             and_return @logger_mock
    Heirloom::CLI::Authorize.any_instance.should_receive(:load_config).
                             with(:logger => @logger_mock,
                                  :opts   => options).
                             and_return @config_mock
    Heirloom::Archive.should_receive(:new).
                      with(:name => 'archive_name',
                           :config => @config_mock).
                      and_return @archive_mock
    Heirloom::Archive.should_receive(:new).
                      with(:id   => '1.0.0',
                           :name => 'archive_name',
                           :config => @config_mock).
                      and_return @archive_mock
    @archive_mock.should_receive(:domain_exists?).and_return true
    @cli_authorize = Heirloom::CLI::Authorize.new
  end

  it "should authorize an account" do
    @archive_mock.should_receive(:authorize).with ['test@test.com']
    @cli_authorize.authorize
  end

end
