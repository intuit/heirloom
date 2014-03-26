require 'spec_helper'

describe Heirloom do

  before do
    @s3_double = double 's3 mock'
    Heirloom::AWS::S3.stub :new => @s3_double

    @config_double = double 'config'
    @logger_double = double 'logger'
    @config_double.stub :logger => @logger_double
    @s3 = Heirloom::Downloader::S3.new :config  => @config_double,
                                       :region  => 'us-west-1'
  end

  context "when succesful" do
    it "should download the specified file from s3" do
      @s3_double.should_receive(:get_object).
               with('bucket', 'key_name').
               and_return 'data'
      @s3.download_file(:key    => 'key_name',
                        :bucket => 'bucket').should == 'data' 
    end
  end

  context "when unsuccesful" do
    before do
      body = '<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<Error><Code>AccessDenied</Code><Message>Access Denied</Message><RequestId>7A737B6941146062</RequestId><HostId>8DlaCTOXO2aBxLnM2cZs+C8pQ2a5IDI/NQJRlPGRbPbBU2U1jH67i0zA376utqyR</HostId></Error>'
      @response_stub = stub 'response', :body => body
    end

    it "should return an error if the bucket not found" do
      @logger_double.should_receive(:error).with('Access Denied')
      @s3_double.should_receive(:get_object).
               with('bucket', 'key_name').
               and_raise Excon::Errors::Forbidden.new 'msg', 'req', @response_stub
      @s3.download_file(:key    => 'key_name',
                        :bucket => 'bucket').should be_false
    end

    it "should return an error if the object not found / forbidden" do
      @logger_double.should_receive(:error).with('Access Denied')
      @s3_double.should_receive(:get_object).
               with('bucket', 'key_name').
               and_raise Excon::Errors::NotFound.new 'msg', 'req', @response_stub
      @s3.download_file(:key    => 'key_name',
                        :bucket => 'bucket').should be_false
    end
  end

end
