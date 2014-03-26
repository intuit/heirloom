require 'spec_helper'

describe Heirloom do

    before do
      @config_double = double 'config'
      @logger_double = double 'logger'
      @logger_double.stub :info => true, :debug => true
      @config_double.should_receive(:logger).and_return(@logger_double)
      @authorizer = Heirloom::Authorizer.new :config => @config_double,
                                             :name   => 'tim',
                                             :id     => '123.tar.gz'
    end

    it "should authorize access to an archive in all regions for email or longid" do
      s3_acl_double = double 's3 acl'
      reader_double = double 'reader mock'
      reader_double.stub :key_name => '123.tar.gz'
      reader_double.should_receive(:get_bucket).exactly(2).times.
                      and_return('the-bucket')

      accounts = [ "test@a.com", "a@test.com", "test@test.co", "test@test.co.uk","08b21b085ca99e70859487d685191f40d951daa0fbcb5bec51bf5ea6023e445d" ]

      Heirloom::Reader.should_receive(:new).
                       with(:config => @config_double,
                            :name   => 'tim',
                            :id     => '123.tar.gz').
                       and_return reader_double
      Heirloom::ACL::S3.should_receive(:new).
                        with(:config => @config_double,
                             :region   => 'us-west-1').
                        and_return s3_acl_double
      Heirloom::ACL::S3.should_receive(:new).
                        with(:config => @config_double,
                             :region   => 'us-west-2').
                        and_return s3_acl_double
      s3_acl_double.should_receive(:allow_read_access_from_accounts).
             exactly(2).times.
             with(:key_name   => '123.tar.gz',
                  :key_folder => 'tim',
                  :bucket     => 'the-bucket',
                  :accounts   => accounts)
      @authorizer.authorize(:accounts => accounts,
                            :regions  => ['us-west-1', 'us-west-2']).
                  should be_true
    end

    it "should exit when an account is a shortid" do
      @logger_double.should_receive(:error)
      @authorizer.authorize(:accounts => [ '123456789_1234', 'good@good.com'],
                            :regions  => ['us-west-1', 'us-west-2']).
                  should be_false
    end

    it "should exit when a bad email is given" do
      @logger_double.should_receive(:error)
      @authorizer.authorize(:accounts => ['bad@bad', 'good@good.com'],
                            :regions  => ['us-west-1', 'us-west-2']).
                  should be_false
    end

    it "should exit when an id which is not long(64) or short(16)" do
      @logger_double.should_receive(:error)
      @authorizer.authorize(:accounts => ['123456789_123456789_1', 'good@good.com'],
                            :regions  => ['us-west-1', 'us-west-2']).
                  should be_false
    end

    it "should exit even when the first value is valid" do
      @logger_double.should_receive(:error)
      @authorizer.authorize(:accounts => ['good@good.com', '123456789_123456789_1'],
                            :regions  => ['us-west-1', 'us-west-2']).
                  should be_false
    end
    
end
