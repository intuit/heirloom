require 'spec_helper'
require 'heirloom/cli'

describe Heirloom do

  before do
    options = { :level     => 'info',
                :base      => 'base',
                :git       => false,
                :exclude   => ['exclude1', 'exclude2'],
                :region    => ['us-west-1', 'us-west-2'],
                :directory => '/buildme',
                :public    => false,
                :name      => 'archive_name',
                :id        => '1.0.0' }

    @logger_stub = stub :error => true, :info => true
    @config_mock = mock 'config'
    @config_mock.stub :logger     => @logger_stub,
                      :access_key => 'key',
                      :secret_key => 'secret'
    @archive_mock = mock 'archive'
    Trollop.stub(:options).and_return options
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
    @upload = Heirloom::CLI::Upload.new
  end

  it "should upload an archive" do
    @upload.stub :ensure_directory => true
    @archive_mock.should_receive(:buckets_exist?).
                  with(:bucket_prefix => 'base',
                       :regions       => ["us-west-1", "us-west-2"]).
                  and_return true
    @archive_mock.stub :exists? => false
    @archive_mock.should_receive(:build).
                  with(:bucket_prefix => 'base',
                       :directory     => '/buildme',
                       :exclude       => ["exclude1", "exclude2"],
                       :git           => false,
                       :secret        => nil).
                  and_return '/tmp/build123.tar.gz'
    @archive_mock.should_receive(:upload).
                  with(:bucket_prefix   => 'base',
                       :regions         => ['us-west-1', 'us-west-2'],
                       :public_readable => false,
                       :file            => '/tmp/build123.tar.gz')
    @upload.upload
  end

end
