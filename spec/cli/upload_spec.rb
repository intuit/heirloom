require 'spec_helper'
require 'heirloom/cli'

describe Heirloom do

  before do
    @regions = ['us-west-1', 'us-west-2']
    options = { :level           => 'info',
                :exclude         => ['exclude1', 'exclude2'],
                :directory       => '/buildme',
                :public          => false,
                :secret          => 'secret12',
                :name            => 'archive_name',
                :id              => '1.0.0', 
                :metadata_region => 'us-west-1' }

    @logger_stub = stub 'logger', :error => true, :info => true
    @config_mock = mock 'config'
    @config_mock.stub :logger          => @logger_stub,
                      :access_key      => 'key',
                      :secret_key      => 'secret',
                      :metadata_region => 'us-west-1'
    @archive_mock = mock 'archive'
    @catalog_mock = mock 'catalog'
    @catalog_mock.stub :regions                => @regions,
                       :bucket_prefix          => 'bp',
                       :catalog_domain_exists? => true
    Trollop.stub(:options).and_return options
    tempfile_stub = stub 'tempfile', :path   => '/tmp/file.tar.gz',
                                     :close! => true
    Tempfile.stub :new => tempfile_stub
    
    Heirloom::HeirloomLogger.should_receive(:new).with(:log_level => 'info').
                             and_return @logger_stub
    Heirloom::CLI::Upload.any_instance.should_receive(:load_config).
                          with(:logger => @logger_stub,
                               :opts   => options).
                          and_return @config_mock
    Heirloom::Archive.should_receive(:new).
                      with(:id   => '1.0.0',
                           :name => 'archive_name',
                           :config => @config_mock).
                      and_return @archive_mock
    Heirloom::Catalog.should_receive(:new).
                      with(:name => 'archive_name',
                           :config => @config_mock).
                      and_return @catalog_mock
    @catalog_mock.should_receive(:entry_exists_in_catalog?).
                  with('archive_name').
                  and_return true
    @upload = Heirloom::CLI::Upload.new
  end

  it "should upload an archive" do
    @upload.should_receive(:ensure_domain_exists).
            with(:name   => 'archive_name',
                 :config => @config_mock)
    @upload.should_receive(:ensure_buckets_exist).
            with(:bucket_prefix => 'bp',
                 :name          => 'archive_name',
                 :regions       => @regions,
                 :config        => @config_mock)
    @upload.should_receive(:ensure_directory).
            with(:path   => '/buildme',
                 :config => @config_mock)
    @upload.should_receive(:ensure_valid_secret).
            with(:secret => 'secret12',
                 :config => @config_mock)
    @archive_mock.stub :exists? => false
    @archive_mock.should_receive(:build).
                  with(:bucket_prefix => 'bp',
                       :directory     => '/buildme',
                       :exclude       => ["exclude1", "exclude2"],
                       :secret        => 'secret12',
                       :file          => '/tmp/file.tar.gz').
                  and_return true
    @archive_mock.should_receive(:upload).
                  with(:bucket_prefix   => 'bp',
                       :regions         => @regions,
                       :public_readable => false,
                       :file            => '/tmp/file.tar.gz')
    @upload.upload
  end

end
