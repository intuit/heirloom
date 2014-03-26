require 'spec_helper'

describe Heirloom do

  before do
    @sdb_double = double 'sdb'
    @config_double = double 'config'
    @logger_double = double :debug => true
    @config_double.stub :logger => @logger_double
    @reader = Heirloom::Reader.new :config => @config_double,
                                   :name   => 'tim',
                                   :id     => '123'
  end

  context "domain does exist" do
    before do
      Heirloom::AWS::SimpleDB.stub :new => @sdb_double
      @sdb_double.stub :domain_exists? => true
    end

    it "should show the item record" do
      @sdb_double.should_receive(:select).
                  with("select * from `heirloom_tim` where itemName() = '123'").
                  and_return( { '123' => { 'value' => [ 'details' ] } } )
      @reader.show.should == { 'value' => 'details' }
    end

    it "should return an empty hash if item does not exist" do
      @sdb_double.should_receive(:select).
                  with("select * from `heirloom_tim` where itemName() = '123'").
                  and_return({})
      @reader.show.should == {}
    end

    it "should return true if the record exists" do
      @sdb_double.should_receive(:select).
                  with("select * from `heirloom_tim` where itemName() = '123'").
                  and_return( { '123' => { 'value' => [ 'details' ] } } )
      @reader.exists?.should == true
    end

    it "should return false if the record does not exist" do
      @sdb_double.should_receive(:select).
                  with("select * from `heirloom_tim` where itemName() = '123'").
                  and_return({})
      @reader.exists?.should == false
    end

    it "should return the bucket if it exists" do
      @sdb_double.should_receive(:select).
                  at_least(:once).
                  with("select * from `heirloom_tim` where itemName() = '123'").
                  and_return( { '123' =>
                                { 'us-west-1-s3-url' =>
                                  [ 's3://the-bucket/the-name/123.tar.gz' ]
                                }
                              } )
      @reader.get_bucket(:region => 'us-west-1').should == 'the-bucket'
    end

    it "should return nil if the key does not exist" do
      @sdb_double.should_receive(:select).
                with("select * from `heirloom_tim` where itemName() = '123'").
                and_return( { } )
      @reader.get_key(:region => 'us-west-1').should == nil
    end

    it "should return nil if the bucket does not exist" do
      @sdb_double.should_receive(:select).
                  with("select * from `heirloom_tim` where itemName() = '123'").
                  and_return( { } )
      @reader.get_bucket(:region => 'us-west-1').should == nil
    end

    it "should return the key if it exists" do
      @sdb_double.should_receive(:select).
                  at_least(:once).
                  with("select * from `heirloom_tim` where itemName() = '123'").
                  and_return( { '123' =>
                                { 'us-west-1-s3-url' =>
                                  ['s3://the-url/the-bucket/123.tar.gz']
                                }
                              } )
      @reader.get_key(:region => 'us-west-1').should == 'the-bucket/123.tar.gz'
    end

    it "should return the encrypted key name" do
      @sdb_double.should_receive(:select).
                  with("select * from `heirloom_tim` where itemName() = '123'").
                  and_return( { '123' => { 'encrypted' => [ 'true' ] } } )
      @reader.key_name.should == '123.tar.gz.gpg'
    end

    it "should return the unencrypted key name" do
      @sdb_double.should_receive(:select).
                  with("select * from `heirloom_tim` where itemName() = '123'").
                  and_return( { '123' => { 'encrypted' => [ 'false' ] } } )
      @reader.key_name.should == '123.tar.gz'
    end

    it "should return the regions the archive has been uploaded to" do
      @sdb_double.should_receive(:select).
                  with("select * from `heirloom_tim` where itemName() = '123'").
                  and_return( { '123' =>
                                { 'us-west-1-s3-url' =>
                                  ['s3://the-url-us-west-1/the-bucket/123.tar.gz'],
                                  'build_by' =>
                                  ['user'],
                                  'us-east-1-s3-url' =>
                                  ['s3://the-url-us-east-1/the-bucket/123.tar.gz']
                                }
                              } )
      @reader.regions.should == ['us-west-1', 'us-east-1']
    end

  end

  context "domain does not exist" do
    before do
      Heirloom::AWS::SimpleDB.stub :new => @sdb_double
      @sdb_double.stub :domain_exists? => false
    end

    it "should return false if the simpledb domain does not exist" do
      @reader.exists?.should == false
    end
  end

  context "object_acl verify" do
    it "should get object_acls" do
      regions = ['us-west-1', 'us-west-2']
      @config_double.stub :access_key => 'the-key',
                          :secret_key => 'the-secret'
      @reader.stub :regions    => regions,
                   :key_name   => 'doublevalue',
                   :get_bucket => 'doublevalue'
      data = { "Owner" => { "ID" => "123", "DisplayName" => "lc" },
               "AccessControlList" => [
                { "Grantee" => { "ID" => "321", "DisplayName" => "rickybobby" },
                                 "Permission" => "READ" },
                { "Grantee" => { "ID" => "123", "DisplayName" => "lc" },
                                 "Permission" => "FULL_CONTROL" }]
             }
      s3_double = double 's3', :get_object_acl => data

      regions.each do |region|
        Heirloom::AWS::S3.should_receive(:new).
                          with(:config => @config_double,
                               :region => region).
                          and_return s3_double
      end

      @reader.object_acls.should == { 'us-west-1-permissions' => 'rickybobby:read, lc:full_control',
                                      'us-west-2-permissions' => 'rickybobby:read, lc:full_control' }
    end
  end

end
