require 'spec_helper'

describe Heirloom do
  before do
    @config_mock = double 'config'
    @logger_mock = double 'logger'
    @config_mock.should_receive(:logger).and_return(@logger_mock)
    @config_mock.should_receive(:authorized_aws_accounts).
                 and_return ['acct1@test.com', 'acct2@test.com']

    @s3 = Heirloom::ACL::S3.new :config  => @config_mock,
                                :region  => 'us-west-1'
  end

  it "should allow read access for the specified accounts" do
    acls = { 
              'Owner' => {
               'Name' => 'Brett',
               'ID' => '123'
              }
           }
    s3_mock = mock 's3'

    @s3.should_receive(:s3).exactly(2).times.
                            and_return(s3_mock)

    s3_mock.should_receive(:get_bucket_acl).with('bucket').
                                            and_return acls

    grants_mock = mock 'grants'
    @s3.should_receive(:build_bucket_grants).
        with(:id   => '123',
             :name => 'Brett',
             :accounts => ['acct1@test.com', 'acct2@test.com']).
        and_return grants_mock

    @logger_mock.should_receive(:info).
                 with 'Authorizing acct1@test.com to s3://bucket/key-folder/key.tar.gz.'
    @logger_mock.should_receive(:info).
                 with 'Authorizing acct2@test.com to s3://bucket/key-folder/key.tar.gz.'

    s3_mock.should_receive(:put_object_acl).with('bucket', 'key-folder/key.tar.gz', grants_mock)

    @s3.allow_read_access_from_accounts :bucket     => 'bucket', 
                                        :key_name   => 'key',
                                        :key_folder => 'key-folder'
  end

  it "should test build_bucket_grants private method"

end
