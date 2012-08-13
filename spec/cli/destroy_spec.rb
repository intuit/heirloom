require 'spec_helper'
require 'heirloom/cli'

describe Heirloom do

  before do
    options = { :name  => 'archive_name',
                :id    => '1.0.0',
                :level => 'info' }
    @logger_mock = mock 'logger'
    @config_mock = mock 'config'
    @archive_mock = mock 'archive'
    Trollop.stub(:options).and_return options
    Heirloom::HeirloomLogger.should_receive(:new).with(:log_level => 'info').
                             and_return @logger_mock
    Heirloom::CLI::Destroy.any_instance.should_receive(:load_config).
                             with(:logger => @logger_mock,
                                  :opts   => options).
                             and_return @config_mock
    Heirloom::Archive.should_receive(:new).
                      with(:id   => '1.0.0',
                           :name => 'archive_name',
                           :config => @config_mock).
                      and_return @archive_mock
    @cli_destroy = Heirloom::CLI::Destroy.new
  end

  it "should destroy an archive" do
    @archive_mock.should_receive(:destroy)
    @cli_destroy.destroy
  end

end
