require 'spec_helper'

describe Heirloom do

  before do
    @config_mock = double 'config'
    @reader = Heirloom::Reader.new :config => @config_mock,
                                   :name   => 'tim',
                                   :id     => '123'
  end

  it "should show the item record" do
    sdb_mock = mock 'sdb'
    @reader.should_receive(:sdb).and_return sdb_mock
    sdb_mock.should_receive(:select).
             with("select * from tim where itemName() = '123'").
             and_return( { '123' => 'details' } )
    @reader.show.should == 'details'
  end

  it "should return true if the record exists" do
    @reader.should_receive(:show).and_return 'a record'
    @reader.exists?.should == true
  end

  it "should return false if the recrod does not exist" do
    @reader.should_receive(:show).and_return nil
    @reader.exists?.should == false
  end

  it "should return the bucket for the specified region" do
    @reader.should_receive(:get_url).
            with(:region => 'us-west-1').
            and_return 's3://bucket-us-west-1/tim/123.tar.gz'
    @reader.get_bucket(:region => 'us-west-1').should == 'bucket-us-west-1'
  end

  it "should return the key" do
    @reader.should_receive(:show).
            and_return( { 'us-west-1-s3-url' => 
                          [ 's3://bucket-us-west-1/tim/123.tar.gz' ] } )
    @reader.should_receive(:get_bucket).
            with(:region => 'us-west-1').
            and_return 'bucket-us-west-1'
    @reader.get_key(:region => 'us-west-1').should == 'tim/123.tar.gz'
  end

  it "shoudl return the s3 url for the given region" do
    @reader.should_receive(:show).
            and_return( { 'us-west-1-s3-url' => 
                           [ 's3://bucket-us-west-1/tim/123.tar.gz' ] } )
    @reader.get_url(:region => 'us-west-1').should == 's3://bucket-us-west-1/tim/123.tar.gz'
  end

end
