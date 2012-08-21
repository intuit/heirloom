require 'spec_helper'
require 'heirloom/cli'

describe Heirloom do

  before do
    options = { :name  => 'archive_name',
                :id    => '1.0.0',
                :level => 'info' }
    @logger_stub = stub 'logger'
    @config_mock = mock 'config'
    @archive_mock = mock 'archive'
    @config_mock.stub :logger     => @logger_stub,
                      :access_key => 'key',
                      :secret_key => 'secret'
    Trollop.stub(:options).and_return options
    Heirloom::HeirloomLogger.should_receive(:new).with(:log_level => 'info').
                             and_return @logger_stub
    Heirloom::CLI::Destroy.any_instance.should_receive(:load_config).
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
    @archive_mock.should_receive(:domain_exists?).and_return true
    @cli_destroy = Heirloom::CLI::Destroy.new
  end

  it "should destroy an archive" do
    @archive_mock.should_receive(:destroy).with :keep_domain => false
    @cli_destroy.destroy
  end

end
