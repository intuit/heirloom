require 'spec_helper'

describe Heirloom do

    before do
      @config_mock = double('config')
      @logger_mock = double('logger')
      @logger_mock.stub :info => true, :debug => true
      @config_mock.should_receive(:logger).and_return(@logger_mock)
      @authorizer = Heirloom::Authorizer.new :config => @config_mock,
                                             :name   => 'tim',
                                             :id     => '123'
    end

    it "should authorize access to an archive in all regions" do
      reader = double
      s3_acl = double
      accounts = [ "test@a.com", "a@test.com", "test@test.co", "test@test.co.uk" ]
      @authorizer.should_receive(:reader).exactly(2).times.
                  and_return(reader)
      reader.should_receive(:get_bucket).exactly(2).times.
                      and_return('the-bucket')
      Heirloom::ACL::S3.should_receive(:new).exactly(2).
                        times.and_return(s3_acl)
      s3_acl.should_receive(:allow_read_access_from_accounts).
             exactly(2).times.
             with(:key_name   => '123',
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
