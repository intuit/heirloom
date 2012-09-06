require 'spec_helper'
require 'heirloom/cli'

describe Heirloom do

  before do
    @logger_stub = stub 'logger'
    @config_mock = mock 'config'
    @archive_mock = mock 'archive'
    @config_mock.stub :logger     => @logger_stub,
                      :access_key => 'key',
                      :secret_key => 'secret',
                      :metadata_region => 'us-west-1'
    Heirloom::HeirloomLogger.should_receive(:new).
                             with(:log_level => 'info').
                             and_return @logger_stub
    Heirloom::Archive.should_receive(:new).
                      with(:id   => '1.0.0',
                           :name => 'archive_name',
                           :config => @config_mock).
                      and_return @archive_mock
  end

  context "with id, region and base specified" do
    before do
      options = { :name            => 'archive_name',
                  :id              => '1.0.0',
                  :base            => 'base',
                  :region          => 'us-east-1',
                  :level           => 'info',
                  :output          => '/tmp/test123',
                  :extract         => false,
                  :metadata_region => 'us-west-1' }
      Trollop.stub(:options).and_return options
      Heirloom::CLI::Download.any_instance.should_receive(:load_config).
                              with(:logger => @logger_stub,
                                   :opts   => options).
                              and_return @config_mock
      @cli_download = Heirloom::CLI::Download.new
    end

    it "should download an archive" do
      @archive_mock.should_receive(:download).with(:output      => '/tmp/test123',
                                                   :region      => 'us-east-1',
                                                   :base_prefix => 'base',
                                                   :extract     => false,
                                                   :secret      => nil).
                    and_return '/tmp/test123'
      @cli_download.should_receive(:ensure_directory).
                    with(:config => @config_mock, 
                         :path => '/tmp/test123').
                    and_return true
      @cli_download.download
    end
  end

  context "id, region and base not specified" do
    before do
      @catalog_stub = stub 'catalog', :regions => ['us-east-1', 'us-west-1'],
                                      :base    => 'base'
      options = { :name            => 'archive_name',
                  :level           => 'info',
                  :output          => '/tmp/test123',
                  :extract         => false,
                  :id              => nil,
                  :metadata_region => 'us-west-1' }
      Trollop.stub(:options).and_return options
      Heirloom::CLI::Download.any_instance.should_receive(:load_config).
                              with(:logger => @logger_stub,
                                   :opts   => options).
                              and_return @config_mock
      Heirloom::Catalog.should_receive(:new).
                        with(:name   => 'archive_name',
                             :config => @config_mock).
                        and_return @catalog_stub
      archive_stub_to_lookup_latest = stub 'latest', :list => ['1.0.0']
      Heirloom::Archive.should_receive(:new).
                        with(:name => 'archive_name',
                             :config => @config_mock).
                        and_return archive_stub_to_lookup_latest
      @cli_download = Heirloom::CLI::Download.new
    end

    it "should download the latest archive from the first region" do
      @archive_mock.should_receive(:download).with(:output      => '/tmp/test123',
                                                   :region      => 'us-east-1',
                                                   :base_prefix => 'base',
                                                   :extract     => false,
                                                   :secret      => nil).
                    and_return '/tmp/test123'
      @cli_download.should_receive(:ensure_directory).
                    with(:config => @config_mock, 
                         :path => '/tmp/test123').
                    and_return true
      @cli_download.download
    end
  end

end
