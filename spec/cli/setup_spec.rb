require 'spec_helper'
require 'heirloom/cli'

describe Heirloom do

  before do
    @regions = ['us-west-1', 'us-west-2']
    options = { :level           => 'info',
                :base            => 'base',
                :region          => @regions,
                :name            => 'archive_name',
                :metadata_region => 'us-west-1' }

    @logger_stub = stub 'logger', :error => true, :info => true
    @config_mock = mock 'config'
    @config_mock.stub :logger          => @logger_stub,
                      :access_key      => 'key',
                      :secret_key      => 'secret',
                      :metadata_region => 'us-west-1'
    @archive_mock = mock 'archive'
    Trollop.stub(:options).and_return options
    Heirloom::HeirloomLogger.should_receive(:new).with(:log_level => 'info').
                             and_return @logger_stub
    Heirloom::CLI::Setup.any_instance.should_receive(:load_config).
                         with(:logger => @logger_stub,
                               :opts   => options).
                          and_return @config_mock
    Heirloom::Archive.should_receive(:new).
                      with(:name => 'archive_name',
                           :config => @config_mock).
                      and_return @archive_mock
    @setup = Heirloom::CLI::Setup.new
  end

  it "should setup s3 buckets and simpledb domain" do
    @setup.should_receive(:ensure_metadata_in_upload_region).
            with(:config  => @config_mock,
                 :regions => @regions)
    @archive_mock.should_receive(:setup).
                  with(:regions       => @regions,
                       :bucket_prefix => 'base')
    @setup.setup 
  end

end
