require 'spec_helper'

describe Heirloom do

  before do
    @config_mock = mock 'config'
    @logger_stub = stub 'logger', :info => true
    @config_mock.stub :logger => @logger_stub
    @uploader = Heirloom::Uploader.new :config => @config_mock,
                                       :name   => 'tim',
                                       :id     => '123'
    @s3_mock = mock 's3'
  end

  it "should upload a new archive" do
    Heirloom::Uploader::S3.should_receive(:new).
                           with(:config => @config_mock,
                                :logger => @logger_stub,
                                :region => 'us-west-1').
                           and_return @s3_mock
    @s3_mock.should_receive(:upload_file).
             with(:bucket          => 'prefix-us-west-1',
                  :file            => '/tmp/file',
                  :id              => '123',
                  :key_folder      => 'tim',
                  :key_name        => "123.tar.gz",
                  :name            => 'tim',
                  :public_readable => true)
    @s3_mock.should_receive(:add_endpoint_attributes).
             with(:bucket   => 'prefix-us-west-1',
                  :id       => '123',
                  :key_name => '123.tar.gz',
                  :name     => 'tim')
    @uploader.upload :file            => '/tmp/file',
                     :bucket_prefix   => 'prefix',
                     :regions         => ['us-west-1'],
                     :public_readable => true,
                     :secret          => nil
  end

  it "should upload a new archive with .gpg if secret provided" do
    Heirloom::Uploader::S3.should_receive(:new).
                           with(:config => @config_mock,
                                :logger => @logger_stub,
                                :region => 'us-west-1').
                           and_return @s3_mock
    @s3_mock.should_receive(:upload_file).
             with(:bucket          => 'prefix-us-west-1',
                  :file            => '/tmp/file',
                  :id              => '123',
                  :key_folder      => 'tim',
                  :key_name        => "123.tar.gz.gpg",
                  :name            => 'tim',
                  :public_readable => true)
    @s3_mock.should_receive(:add_endpoint_attributes).
             with(:bucket   => 'prefix-us-west-1',
                  :id       => '123',
                  :key_name => '123.tar.gz.gpg',
                  :name     => 'tim')
    @uploader.upload :file            => '/tmp/file',
                     :bucket_prefix   => 'prefix',
                     :regions         => ['us-west-1'],
                     :public_readable => true,
                     :secret          => 'secret12'
  end

end
