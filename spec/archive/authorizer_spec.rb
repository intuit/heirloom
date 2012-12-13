require 'spec_helper'

describe Heirloom do

    before do
      @config_mock = mock 'config'
      @logger_mock = mock 'logger'
      @logger_mock.stub :info => true, :debug => true
      @config_mock.should_receive(:logger).and_return(@logger_mock)
      @authorizer = Heirloom::Authorizer.new :config => @config_mock,
                                             :name   => 'tim',
                                             :id     => '123.tar.gz'
    end

    it "should authorize access to an archive in all regions" do
      s3_acl_mock = mock 's3 acl'
      reader_mock = mock 'reader mock'
      reader_mock.stub :key_name => '123.tar.gz'
      reader_mock.should_receive(:get_bucket).exactly(2).times.
                      and_return('the-bucket')

      accounts = [ "test@a.com", "a@test.com", "test@test.co", "test@test.co.uk" ]

      Heirloom::Reader.should_receive(:new).
                       with(:config => @config_mock,
                            :name   => 'tim',
                            :id     => '123.tar.gz').
                       and_return reader_mock
      Heirloom::ACL::S3.should_receive(:new).
                        with(:config => @config_mock,
                             :region   => 'us-west-1').
                        and_return s3_acl_mock
      Heirloom::ACL::S3.should_receive(:new).
                        with(:config => @config_mock,
                             :region   => 'us-west-2').
                        and_return s3_acl_mock
      s3_acl_mock.should_receive(:allow_read_access_from_accounts).
             exactly(2).times.
             with(:key_name   => '123.tar.gz',
                  :key_folder => 'tim',
                  :bucket     => 'the-bucket',
                  :accounts   => accounts)
      @authorizer.authorize(:accounts => accounts,
                            :regions  => ['us-west-1', 'us-west-2']).
                  should be_true
    end

    it "should exit when an account is not an email" do
      @logger_mock.should_receive(:error)
      @authorizer.authorize(:accounts => ['good@good.com', 'bad@blah'],
                            :regions  => ['us-west-1', 'us-west-2']).
                  should be_false
    end


end
