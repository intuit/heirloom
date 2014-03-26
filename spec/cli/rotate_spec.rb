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

    catalog_double = double :regions => ['us-east-1', 'us-west-1']
    Heirloom::Catalog.stub(:new).and_return catalog_double

    @archive_double = double 'archive'
    @logger_double  = double_log
    Heirloom::HeirloomLogger.stub :new => @logger_double
    Heirloom::Archive.stub(:new).and_return @archive_double

  end

  it "should delegate to archive object" do

    @archive_double.should_receive :rotate

    Heirloom::CLI::Rotate.new.rotate

  end

  it "should log and do a SystemExit when a rotate fails" do
    
    @archive_double.stub(:rotate).and_raise Heirloom::Exceptions::RotateFailed.new("failed")

    @logger_double.should_receive(:error).with "failed"
    expect {
      Heirloom::CLI::Rotate.new.rotate
    }.to raise_error SystemExit
    
  end
  
end
