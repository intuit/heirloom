require 'spec_helper'
require 'heirloom/cli'

describe Heirloom do

  before do

    options = { :name           => 'archive_name',
                :id             => '1.0.0',
                :bucket_prefix  => 'bp',
                :old_secret     => 'oldpassword',
                :new_secret     => 'newpassword',
                :aws_access_key => 'key',
                :aws_secret_key => 'secret' }
    Trollop.stub(:options).and_return options

    catalog_stub = stub :regions => ['us-east-1', 'us-west-1']
    Heirloom::Catalog.stub(:new).and_return catalog_stub

    @archive_mock = mock 'archive'
    @logger_mock = mock_log
    Heirloom::HeirloomLogger.stub :new => @logger_mock
    Heirloom::Archive.stub(:new).and_return @archive_mock

  end

  it "should delegate to archive object" do

    @archive_mock.should_receive :rotate

    Heirloom::CLI::Rotate.new.rotate

  end

  it "should log and do a SystemExit when a rotate fails" do
    
    @archive_mock.stub(:rotate).and_raise Heirloom::Exceptions::RotateFailed.new("failed")

    @logger_mock.should_receive(:error).with "failed"
    expect {
      Heirloom::CLI::Rotate.new.rotate
    }.to raise_error SystemExit
    
  end
  
end
