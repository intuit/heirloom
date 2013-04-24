require 'spec_helper'
require 'heirloom/cli'

describe Heirloom do

  before do
    options = { :level           => 'info',
                :accounts        => ['test@test.com'],
                :name            => 'archive_name',
                :id              => '1.0.0',
                :metadata_region => 'us-west-1' }
    @logger_stub = stub 'logger', :error => true
    @config_mock = mock_config :logger => @logger_stub
    @archive_mock = mock 'archive'
    Trollop.stub(:options).and_return options
    Heirloom::HeirloomLogger.should_receive(:new).with(:log_level => 'info').
                             and_return @logger_stub
    Heirloom::CLI::Authorize.any_instance.should_receive(:load_config).
                             with(:logger => @logger_stub,
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
    @archive_mock.stub :exists? => true
    @archive_mock.should_receive(:domain_exists?).and_return true
    @cli_authorize = Heirloom::CLI::Authorize.new
  end

  it "should authorize an account" do
    @archive_mock.should_receive(:authorize).with(['test@test.com']).
                  and_return true
    @cli_authorize.authorize
  end

  it "should exit if authorize returns false" do
    @archive_mock.should_receive(:authorize).with(['test@test.com']).
                  and_return false
    lambda { @cli_authorize.authorize }.should raise_error SystemExit
  end

end
