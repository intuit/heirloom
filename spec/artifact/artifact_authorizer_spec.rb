require 'spec_helper'

describe Heirloom do

    before do
      @config_mock = double('config')
      @logger_mock = double('logger')
      @config_mock.should_receive(:logger).and_return(@logger_mock)
      @authorizer = Heirloom::ArtifactAuthorizer.new :config => @config_mock,
                                                     :name   => 'tim',
                                                     :id     => '123'
    end

    it "should authorize access to an acl across all regions" do
      artifact_reader = double
      s3_acl = double
      @logger_mock.should_receive(:info).exactly(2).times
      @config_mock.should_receive(:regions).
                   and_return(['us-west-1', 'us-west-2'])
      @authorizer.should_receive(:artifact_reader).exactly(2).times.
                  and_return(artifact_reader)
      artifact_reader.should_receive(:get_bucket).exactly(2).times.
                      and_return('the-bucket')
      Heirloom::ACL::S3.should_receive(:new).exactly(2).
                        times.and_return(s3_acl)
      s3_acl.should_receive(:allow_read_access_from_accounts).
             exactly(2).times.
             with(:key_name   => '123',
                  :key_folder => 'tim',
                  :bucket     => 'the-bucket')
      @authorizer.authorize
    end

end
