require 'spec_helper'

describe Heirloom do
  before do
    @config_mock = mock 'config'
    @config_mock.should_receive(:access_key).and_return 'the-key'
    @config_mock.should_receive(:secret_key).and_return 'the-secret'
    @fog_mock = mock 'fog'
    Fog::Storage.should_receive(:new).and_return @fog_mock
    @s3 = Heirloom::AWS::S3.new :config => @config_mock,
                                :region => 'us-west-1'


  end

  it "should delete an object from s3" do
    @fog_mock.should_receive(:delete_object).
              with('bucket', 'object', { :option => 'test' })
    @s3.delete_object('bucket', 'object', { :option => 'test' })
  end

  it "should get a bucket from s3" do
    directories_mock = mock 'directories'
    @fog_mock.should_receive(:directories).
              and_return directories_mock
    directories_mock.should_receive(:get).with 'bucket'
    @s3.get_bucket 'bucket'
  end

  it "should get an object from s3" do
    body_mock = mock 'body'
    @fog_mock.should_receive(:get_object).
              with('bucket', 'object').
              and_return body_mock
    body_mock.should_receive(:body)
    @s3.get_object('bucket', 'object')
  end

  it "should get a buckets acl from s3" do
    body_mock = mock 'body'
    @fog_mock.should_receive(:get_object).
              with('bucket', 'object').
              and_return body_mock
    body_mock.should_receive(:body)
    @s3.get_object('bucket', 'object')
  end

  it "should set object acls" do
    @fog_mock.should_receive(:put_object_acl).
              with 'bucket', 'object', 'grants'
    @s3.put_object_acl 'bucket', 'object', 'grants'
  end

  it "should call put bucket with location_constraint us-west-1" do
    options = { 'LocationConstraint' => 'us-west-1',
                'x-amz-acl'          => 'private' }
    @fog_mock.should_receive(:put_bucket).
              with('name', options)
    @s3.put_bucket 'name', 'us-west-1'
  end

  it "should call put bucket with location_constraint nil when region us-west-1" do
    options = { 'LocationConstraint' => nil,
                'x-amz-acl'          => 'private' }
    @fog_mock.should_receive(:put_bucket).
              with('name', options)
    @s3.put_bucket 'name', 'us-east-1'
  end


end
