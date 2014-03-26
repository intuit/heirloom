require 'spec_helper'
require 'heirloom/cli'

describe Heirloom do

  before do
    @logger_double = double 'logger'
    @config_double = double_config :logger => @logger_double
    @archive_double = double 'archive'
    Heirloom::HeirloomLogger.should_receive(:new).
                             with(:log_level => 'info').
                             and_return @logger_double
    Heirloom::Archive.should_receive(:new).
                      with(:id     => '1.0.0',
                           :name   => 'archive_name',
                           :config => @config_double).
                      and_return @archive_double
  end

  context "with id, region and bucket_prefix specified" do
    before do
      options = { :name            => 'archive_name',
                  :id              => '1.0.0',
                  :bucket_prefix   => 'bp',
                  :region          => 'us-east-1',
                  :level           => 'info',
                  :output          => '/tmp/test123',
                  :extract         => false,
                  :metadata_region => 'us-west-1' }
      Trollop.stub(:options).and_return options
      Heirloom::CLI::Download.any_instance.should_receive(:load_config).
                              with(:logger => @logger_double,
                                   :opts   => options).
                              and_return @config_double
      @cli_download = Heirloom::CLI::Download.new
    end

    it "should download an archive" do
      @archive_double.should_receive(:download).with(:output        => '/tmp/test123',
                                                     :region        => 'us-east-1',
                                                     :bucket_prefix => 'bp',
                                                     :extract     => false,
                                                     :secret      => nil).
                    and_return '/tmp/test123'
      @cli_download.should_receive(:ensure_path_is_directory).
                    with(:config => @config_double,
                         :path => '/tmp/test123').
                    and_return true
      @cli_download.should_receive(:ensure_directory_is_writable).
                    with(:config => @config_double,
                         :path => '/tmp/test123').
                    and_return true
      @cli_download.download
    end
  end

  context "id, region and bucket prefix not specified" do
    before do
      @catalog_double = double 'catalog', :regions       => ['us-east-1', 'us-west-1'],
                                          :bucket_prefix => 'bp'
      @archive_double.stub :exists? => true
      options = { :name            => 'archive_name',
                  :level           => 'info',
                  :output          => '/tmp/test123',
                  :extract         => false,
                  :id              => nil,
                  :metadata_region => 'us-west-1' }
      Trollop.stub(:options).and_return options
      Heirloom::CLI::Download.any_instance.should_receive(:load_config).
                              with(:logger => @logger_double,
                                   :opts   => options).
                              and_return @config_double
      Heirloom::Catalog.should_receive(:new).
                        with(:name   => 'archive_name',
                             :config => @config_double).
                        and_return @catalog_double
      archive_double_to_lookup_latest = double 'latest', :list => ['1.0.0']
      Heirloom::Archive.should_receive(:new).
                        with(:name => 'archive_name',
                             :config => @config_double).
                        and_return archive_double_to_lookup_latest
      @cli_download = Heirloom::CLI::Download.new
    end

    it "should download the latest archive from the first region" do
      @archive_double.should_receive(:download).with(:output        => '/tmp/test123',
                                                   :region        => 'us-east-1',
                                                   :bucket_prefix => 'bp',
                                                   :extract       => false,
                                                   :secret        => nil).
                      and_return '/tmp/test123'
      @cli_download.should_receive(:ensure_path_is_directory).
                    with(:config => @config_double,
                         :path => '/tmp/test123').
                    and_return true
      @cli_download.should_receive(:ensure_directory_is_writable).
                    with(:config => @config_double,
                         :path => '/tmp/test123').
                    and_return true
      @cli_download.download
    end
  end

end
