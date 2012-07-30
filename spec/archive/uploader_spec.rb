require 'spec_helper'

describe Heirloom do

  before do
    @config_mock = double 'config'
    @logger_mock = double 'logger'
    @config_mock.should_receive(:logger).and_return(@logger_mock)
    @uploader = Heirloom::Uploader.new :config => @config_mock,
                                       :name   => 'tim',
                                       :id     => '123'
  end

  it "should upload a new archive" do
    s3_mock = mock 's3'
    Heirloom::Uploader::S3.should_receive(:new).
                           with(:config => @config_mock,
                                :logger => @logger_mock,
                                :region => 'us-west-1').
                           and_return s3_mock
    s3_mock.should_receive(:upload_file).
            with(:bucket          => 'prefix-us-west-1',
                 :file            => '/tmp/file',
                 :id              => '123',
                 :key_folder      => 'tim',
                 :key_name        => "123.tar.gz",
                 :name            => 'tim',
                 :public_readable => true)
    s3_mock.should_receive(:add_endpoint_attributes).
            with(:bucket => 'prefix-us-west-1',
                 :id     => '123',
                 :name   => 'tim')
    @logger_mock.should_receive(:info)
    @uploader.upload :file            => '/tmp/file',
                     :bucket_prefix   => 'prefix',
                     :regions         => ['us-west-1'],
                     :public_readable => true
  end

end
