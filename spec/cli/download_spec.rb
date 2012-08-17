require 'spec_helper'
require 'heirloom/cli'

describe Heirloom do

  before do
    options = { :name        => 'archive_name',
                :id          => '1.0.0',
                :level       => 'info',
                :output      => '/tmp/test123',
                :region      => 'us-east-1',
                :extract     => false,
                :base_prefix => 'base' }
    @logger_stub = stub 'logger'
    @config_mock = mock 'config'
    @archive_mock = mock 'archive'
    @config_mock.stub :logger     => @logger_stub,
                      :access_key => 'key',
                      :secret_key => 'secret'
    Trollop.stub(:options).and_return options
    Heirloom::HeirloomLogger.should_receive(:new).
                             with(:log_level => 'info').
                             and_return @logger_stub
    Heirloom::CLI::Download.any_instance.should_receive(:load_config).
                            with(:logger => @logger_stub,
                                 :opts   => options).
                            and_return @config_mock
    Heirloom::Archive.should_receive(:new).
                      with(:id   => '1.0.0',
                           :name => 'archive_name',
                           :config => @config_mock).
                      and_return @archive_mock
    @cli_download = Heirloom::CLI::Download.new
  end

  it "should download an archive" do
    @archive_mock.should_receive(:download).with :output      => '/tmp/test123',
                                                 :region      => 'us-east-1',
                                                 :base_prefix => 'base',
                                                 :extract     => false
    @cli_download.download
  end

end
