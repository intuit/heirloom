require 'spec_helper'

describe Heirloom do
  before do
    @directories_mock = mock 'directories'
    @bucket_mock = mock 'bucket'
    @logger_stub = stub 'logger', :debug => true, 
                                  :info  => true,
                                  :warn  => true
    @config_mock = mock 'config'
    @config_mock.stub :access_key => 'the-key',
                      :secret_key => 'the-secret',
                      :logger     => @logger_stub
    @fog_mock = mock 'fog'
    @fog_mock.stub :directories => @directories_mock
    Fog::Storage.should_receive(:new).and_return @fog_mock
    @s3 = Heirloom::AWS::S3.new :config => @config_mock,
                                :region => 'us-west-1'
  end

  context "bucket_exists?" do
    it "should return true if the bucket exists" do
      @directories_mock.should_receive(:get).
                        with('bucket').and_return @bucket_mock
      @s3.bucket_exists?('bucket').should be_true
    end

    it "should return false if the bucket does not exist" do
      @directories_mock.should_receive(:get).
                        with('bucket').and_return nil
      @s3.bucket_exists?('bucket').should be_false
    end

    it "should return false if bucket owned by another account" do
      @directories_mock.should_receive(:get).
                        with('bucket').
                        and_raise Excon::Errors::Forbidden.new('msg')
      @s3.bucket_exists?('bucket').should be_false
    end
  end

  context "bucket_exists_in_another_region?" do
    it "should return true if the bucket exists in another region" do
      @bucket_mock.stub :location => 'us-east-1'
      @directories_mock.should_receive(:get).
                        with('bucket').at_least(:once).
                        and_return @bucket_mock
      @s3.bucket_exists_in_another_region?('bucket').should be_true
    end

    it "should return false if the bucket exists in the curren region" do
      @bucket_mock.stub :location => 'us-west-1'
      @directories_mock.should_receive(:get).
                        with('bucket').at_least(:once).
                        and_return @bucket_mock
      @s3.bucket_exists_in_another_region?('bucket').should be_false
    end

    it "should return false if bucket owned by another account" do
      @directories_mock.should_receive(:get).
                        with('bucket').
                        and_raise Excon::Errors::Forbidden.new('msg')
      @s3.bucket_exists_in_another_region?('bucket').should be_false
    end
  end

  context "bucket_owned_by_another_account?" do
    it "should return false if bucket owned by this account" do
      @directories_mock.should_receive(:get).
                        with('bucket').
                        and_return @bucket_mock
      @s3.bucket_owned_by_another_account?('bucket').should be_false
    end

    it "should return false if bucket does not exist" do
      @directories_mock.should_receive(:get).
                        with('bucket').
                        and_return nil
      @s3.bucket_owned_by_another_account?('bucket').should be_false
    end

    it "should return true if bucket is not owned by another account" do
      @directories_mock.should_receive(:get).
                        with('bucket').
                        and_raise Excon::Errors::Forbidden.new('msg')
      @s3.bucket_owned_by_another_account?('bucket').should be_true
    end
  end

  it "should delete an object from s3" do
    @fog_mock.should_receive(:delete_object).
              with('bucket', 'object', { :option => 'test' })
    @s3.delete_object('bucket', 'object', { :option => 'test' })
  end

  it "should get a bucket from s3" do
    @directories_mock.should_receive(:get).with 'bucket'
    @s3.get_bucket 'bucket'
  end

  context "testing bucket availability" do

    it "should return false if the bucket is forbidden" do
      @directories_mock.should_receive(:get).
                  with('bucket').
                  and_raise Excon::Errors::Forbidden.new('msg')
      @s3.bucket_name_available?('bucket').should be_false
    end

    it "should return false if bucket in different region" do
      @directories_mock.should_receive(:get).
                  with('bucket').at_least(:once).
                  and_return @bucket_mock
      @bucket_mock.stub :location => 'us-east-1'
      @s3.bucket_name_available?('bucket').should be_false
    end

    it "should return true if the bucket is in this account / region" do
      @directories_mock.should_receive(:get).
                with('bucket').at_least(:once).
                and_return @bucket_mock
      @bucket_mock.stub :location => 'us-west-1'
      @s3.bucket_name_available?('bucket').should be_true
    end

    it "should return true if the bucket is not found" do
      @directories_mock.should_receive(:get).
                        with('bucket').at_least(:once).
                        and_return nil
      @s3.bucket_name_available?('bucket').should be_true
    end

  end

  it "should return object versions for a given bucket" do
    body_mock = mock 'body'
    @fog_mock.should_receive(:get_bucket_object_versions).
              with('bucket').
              and_return body_mock
    body_mock.stub :body => 'body_hash'
    @s3.get_bucket_object_versions('bucket').should == 'body_hash'
  end

  context "testing bucket deletion" do
    it "should return true if the bucket has 0 objects" do
      body_mock = mock 'body'
      @fog_mock.should_receive(:get_bucket_object_versions).
                with('bucket').
                and_return body_mock
      body_mock.stub :body => { "Versions" => [ ] }
      @s3.bucket_empty?('bucket').should be_true
    end

    it "should return false if the bucket has any objects" do
      body_mock = mock 'body'
      @fog_mock.should_receive(:get_bucket_object_versions).
                with('bucket').
                and_return body_mock
      body_mock.stub :body => { "Versions" => [ 'obj1', 'obj2' ] }
      @s3.bucket_empty?('bucket').should be_false
    end

    it "should delete a bucket from s3 if empty" do
      body_mock = mock 'body'
      @fog_mock.should_receive(:get_bucket_object_versions).
                with('bucket').
                and_return body_mock
      body_mock.stub :body => { "Versions" => [ ] }
      @fog_mock.should_receive(:delete_bucket).
                with('bucket').and_return true
      @s3.delete_bucket('bucket').should be_true
    end

    it "should return false and not attempt to delete a non empty s3 bucket" do
      body_mock = mock 'body'
      @fog_mock.should_receive(:get_bucket_object_versions).
                with('bucket').
                and_return body_mock
      body_mock.stub :body => { "Versions" => [ 'obj1', 'obj2' ] }
      @fog_mock.should_receive(:delete_bucket).never
      @s3.delete_bucket('bucket').should be_false
    end

    it "should return true if Excon::Errors::NotFound raised when deleting bucket" do
      @fog_mock.should_receive(:get_bucket_object_versions).
                with('bucket').
                and_raise Excon::Errors::NotFound.new 'Bucket does not exist.'
      @fog_mock.should_receive(:delete_bucket).never
      @s3.delete_bucket('bucket').should be_true
    end
  end

  it "should get an object from s3" do
    body_mock = mock 'body'
    @fog_mock.should_receive(:get_object).
              with('bucket', 'object').
              and_return body_mock
    body_mock.stub :body => 'body_hash'
    @s3.get_object('bucket', 'object').should == 'body_hash'
  end

  it "should get a buckets acl from s3" do
    body_mock = mock 'body'
    @fog_mock.should_receive(:get_object).
              with('bucket', 'object').
              and_return body_mock
    body_mock.should_receive(:body)
    @s3.get_object('bucket', 'object')
  end

  it "should get an objects acl from s3" do
    body_mock = mock 'body'
    @fog_mock.should_receive(:get_object_acl).
              with('bucket', 'object').
              and_return body_mock
    body_mock.should_receive(:body)
    @s3.get_object_acl({ :bucket => 'bucket', :object_name => 'object'})
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
