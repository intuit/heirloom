require 'spec_helper'

describe Heirloom do
  before do
    @config_double = double 'config'
    @logger_double = double 'logger', :info => true, :debug => true
    @config_double.stub :logger => @logger_double

    @s3 = Heirloom::ACL::S3.new :config  => @config_double,
                                :region  => 'us-west-1'
  end

  it "should allow read access for the specified accounts" do
    acls = { 
              'Owner' => {
               'Name' => 'Brett',
               'ID' => '123'
              }
           }
    s3_double = double 's3'

    @s3.should_receive(:s3).exactly(2).times.
                            and_return(s3_double)

    s3_double.should_receive(:get_object_acl).
              with(:bucket => 'bucket', :object_name => 'key-folder/key.tar.gz').
              and_return acls

    s3_double.should_receive(:put_object_acl).
              with("bucket", "key-folder/key.tar.gz", {"Owner"=>{"DisplayName"=>"Brett", "ID"=>"123"}, "AccessControlList"=>[{"Grantee"=>{"EmailAddress"=>"acct1@test.com"}, "Permission"=>"READ"}, {"Grantee"=>{"EmailAddress"=>"acct2@test.com"}, "Permission"=>"READ"}, {"Grantee"=>{"DisplayName"=>"Brett", "ID"=>"123"}, "Permission"=>"FULL_CONTROL"}]})

    @s3.allow_read_access_from_accounts :bucket     => 'bucket', 
                                        :key_name   => 'key.tar.gz',
                                        :key_folder => 'key-folder',
                                        :accounts   => ['acct1@test.com', 'acct2@test.com']
  end

end
