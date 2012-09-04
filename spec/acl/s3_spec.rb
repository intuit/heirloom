require 'spec_helper'

describe Heirloom do
  before do
    @config_mock = double 'config'
    @logger_stub = stub 'logger', :info => true, :debug => true
    @config_mock.stub :logger => @logger_stub

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

    s3_mock.should_receive(:put_object_acl).
            with("bucket", "key-folder/key.tar.gz", {"Owner"=>{"DisplayName"=>"Brett", "ID"=>"123"}, "AccessControlList"=>[{"Grantee"=>{"EmailAddress"=>"acct1@test.com"}, "Permission"=>"READ"}, {"Grantee"=>{"EmailAddress"=>"acct2@test.com"}, "Permission"=>"READ"}, {"Grantee"=>{"DisplayName"=>"Brett", "ID"=>"123"}, "Permission"=>"FULL_CONTROL"}]})

    @s3.allow_read_access_from_accounts :bucket     => 'bucket', 
                                        :key_name   => 'key',
                                        :key_folder => 'key-folder',
                                        :accounts   => ['acct1@test.com', 'acct2@test.com']
  end

end
