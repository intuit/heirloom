require 'spec_helper'

describe Heirloom do

  before do
    @sdb_mock = mock 'sdb'
    @config_mock = mock 'config'
    @logger_stub = stub :debug => true
    @config_mock.should_receive(:logger).and_return @logger_stub
    Heirloom::AWS::SimpleDB.should_receive(:new).and_return @sdb_mock
    @reader = Heirloom::Reader.new :config => @config_mock,
                                   :name   => 'tim',
                                   :id     => '123'
  end

  context "domain does exist" do
    before do
      @sdb_mock.stub :domain_exists? => true
    end

    it "should show the item record" do
      @sdb_mock.should_receive(:select).
               with("select * from `heirloom_tim` where itemName() = '123'").
               and_return( { '123' => { 'value' => [ 'details' ] } } )
      @reader.show.should == { 'value' => 'details' }
    end

    it "should get object_acls" do
      @reader.stub(:regions).and_return( ['us-west-1', 'us-east-1'] )
      @reader.stub(:key_name).and_return( 'mockvalue' )
      @reader.stub(:get_bucket).and_return( 'mockvalue' )
      #@region_mock = mock 'us-west-1'
      @sdb_mock.stub(:select).and_return('value')
      @s3_acl_mock = mock 's3'
      Heirloom::AWS::S3.should_receive(:new).exactly(2).times.and_return @s3_acl_mock
      @s3_acl_mock.stub(:get_object_acl).and_return(
        {"Owner"=>{"ID"=>"123", "DisplayName"=>"lc"}, 
          "AccessControlList"=>[
            {"Grantee"=>{"ID"=>"321", "DisplayName"=>"rickybobby"}, "Permission"=>"READ"}, 
            {"Grantee"=>{"ID"=>"123", "DisplayName"=>"lc"}, "Permission"=>"FULL_CONTROL"}]
        })

      @reader.show.should == {} 
      @reader.object_acls.should == { 'us-west-1-perms' => 'rickybobby:read, lc:full_control', 
                                      'us-east-1-perms' => 'rickybobby:read, lc:full_control'
                                    } 
    end

    it "should return an empty hash if item does not exist" do
      @sdb_mock.should_receive(:select).
                with("select * from `heirloom_tim` where itemName() = '123'").
                and_return({})
      @reader.show.should == {}
    end

    it "should return true if the record exists" do
      @sdb_mock.should_receive(:select).
                with("select * from `heirloom_tim` where itemName() = '123'").
                and_return( { '123' => { 'value' => [ 'details' ] } } )
      @reader.exists?.should == true
    end

    it "should return false if the record does not exist" do
      @sdb_mock.should_receive(:select).
                with("select * from `heirloom_tim` where itemName() = '123'").
                and_return({})
      @reader.exists?.should == false
    end

    it "should return the bucket if it exists" do
      @sdb_mock.should_receive(:select).
                exactly(3).times.
                with("select * from `heirloom_tim` where itemName() = '123'").
                and_return( { '123' => 
                              { 'us-west-1-s3-url' => 
                                [ 's3://the-bucket/the-name/123.tar.gz' ]  
                              }
                            } )
      @reader.get_bucket(:region => 'us-west-1').should == 'the-bucket'
    end

    it "should return nil if the key does not exist" do
      @sdb_mock.should_receive(:select).
                exactly(1).times.
                with("select * from `heirloom_tim` where itemName() = '123'").
                and_return( { } )
      @reader.get_key(:region => 'us-west-1').should == nil
    end

    it "should return nil if the bucket does not exist" do
      @sdb_mock.should_receive(:select).
                exactly(1).times.
                with("select * from `heirloom_tim` where itemName() = '123'").
                and_return( { } )
      @reader.get_bucket(:region => 'us-west-1').should == nil
    end

    it "should return the key if it exists" do
      @sdb_mock.should_receive(:select).
                exactly(6).times.
                with("select * from `heirloom_tim` where itemName() = '123'").
                and_return( { '123' => 
                              { 'us-west-1-s3-url' => 
                                ['s3://the-url/the-bucket/123.tar.gz'] 
                              }
                            } )
      @reader.get_key(:region => 'us-west-1').should == 'the-bucket/123.tar.gz'
    end

    it "should return the encrypted key name" do
      @sdb_mock.should_receive(:select).
                with("select * from `heirloom_tim` where itemName() = '123'").
                and_return( { '123' => { 'encrypted' => [ 'true' ] } } )
      @reader.key_name.should == '123.tar.gz.gpg'
    end

    it "should return the unencrypted key name" do
      @sdb_mock.should_receive(:select).
                with("select * from `heirloom_tim` where itemName() = '123'").
                and_return( { '123' => { 'encrypted' => [ 'false' ] } } )
      @reader.key_name.should == '123.tar.gz'
    end

    it "should return the regions the archive has been uploaded to" do
      @sdb_mock.should_receive(:select).
                exactly(1).times.
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
      @sdb_mock.stub :domain_exists? => false
    end

    it "should return false if the simpledb domain does not exist" do
      @reader.exists?.should == false
    end
  end

end
