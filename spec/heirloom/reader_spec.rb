require 'spec_helper'

describe Heirloom do

  before do
    @sdb_mock = mock 'sdb'
    @config_mock = double 'config'
    @logger_mock = double 'logger'
    @config_mock.should_receive(:logger).and_return @logger_mock
    Heirloom::AWS::SimpleDB.should_receive(:new).and_return @sdb_mock
    @reader = Heirloom::Reader.new :config => @config_mock,
                                   :name   => 'tim',
                                   :id     => '123'
  end

  it "should show the item record" do
    @sdb_mock.should_receive(:select).
             with("select * from tim where itemName() = '123'").
             and_return( { '123' => { 'value' => 'details' } } )
    @reader.show.should == { 'value' => 'details' }
  end

  it "should return an empty hash if item does not exist" do
    @sdb_mock.should_receive(:select).
              with("select * from tim where itemName() = '123'").
              and_return({})
    @reader.show.should == {}
  end

  it "should return true if the record exists" do
    @sdb_mock.should_receive(:select).
              with("select * from tim where itemName() = '123'").
              and_return( { '123' => { 'value' => 'details' } } )
    @logger_mock.should_receive(:debug).exactly(1).times
    @reader.exists?.should == true
  end

  it "should return false if the recrod does not exist" do
    @sdb_mock.should_receive(:select).
              with("select * from tim where itemName() = '123'").
              and_return({})
    @logger_mock.should_receive(:debug).exactly(1).times
    @reader.exists?.should == false
  end

  it "should return the bucket if it exists" do
    @logger_mock.should_receive(:debug).exactly(5).times
    @sdb_mock.should_receive(:select).
              exactly(3).times.
              with("select * from tim where itemName() = '123'").
              and_return( { '123' => 
                            { 'us-west-1-s3-url' => 
                              ['s3://the-url/the-buck/the-key'] 
                            }
                          } )
    @reader.get_bucket(:region => 'us-west-1').should == 'the-url'
  end

  it "should return nil if the bucket does not exist" do
    @logger_mock.should_receive(:debug).exactly(3).times
    @sdb_mock.should_receive(:select).
              exactly(1).times.
              with("select * from tim where itemName() = '123'").
              and_return( { } )
    @reader.get_bucket(:region => 'us-west-1').should == nil
  end

  it "should return the key if it exists" do
    @logger_mock.should_receive(:debug).exactly(8).times
    @sdb_mock.should_receive(:select).
              exactly(6).times.
              with("select * from tim where itemName() = '123'").
              and_return( { '123' => 
                            { 'us-west-1-s3-url' => 
                              ['s3://the-url/the-bucket/the-key'] 
                            }
                          } )
    @reader.get_key(:region => 'us-west-1').should == 'the-bucket/the-key'
  end

  it "should return nil if the key does not exist" do
    @logger_mock.should_receive(:debug).exactly(1).times
    @sdb_mock.should_receive(:select).
              exactly(1).times.
              with("select * from tim where itemName() = '123'").
              and_return( { } )
    @reader.get_key(:region => 'us-west-1').should == nil
  end

end
