require 'spec_helper'

describe Heirloom do

  before do
    @config_double = double 'config'
    @logger_double = double 'logger', :info => true
    @config_double.stub :logger => @logger_double
    @uploader = Heirloom::Uploader.new :config => @config_double,
                                       :name   => 'tim',
                                       :id     => '123'
    @s3_double = double 's3'
  end

  it "should upload a new archive" do
    Heirloom::Uploader::S3.should_receive(:new).
                           with(:config => @config_double,
                                :logger => @logger_double,
                                :region => 'us-west-1').
                           and_return @s3_double
    @s3_double.should_receive(:upload_file).
             with(:bucket          => 'prefix-us-west-1',
                  :file            => '/tmp/file',
                  :id              => '123',
                  :key_folder      => 'tim',
                  :key_name        => "123.tar.gz",
                  :name            => 'tim',
                  :public_readable => true)
    @s3_double.should_receive(:add_endpoint_attributes).
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
                           with(:config => @config_double,
                                :logger => @logger_double,
                                :region => 'us-west-1').
                           and_return @s3_double
    @s3_double.should_receive(:upload_file).
               with(:bucket          => 'prefix-us-west-1',
                    :file            => '/tmp/file',
                    :id              => '123',
                    :key_folder      => 'tim',
                    :key_name        => "123.tar.gz.gpg",
                    :name            => 'tim',
                    :public_readable => true)
    @s3_double.should_receive(:add_endpoint_attributes).
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
