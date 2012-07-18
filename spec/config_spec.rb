require 'spec_helper'

describe Heirloom do

  before do
    @config = { 'aws' => 
                { 'access_key'              => 'key',
                  'secret_key'              => 'secret',
                  'regions'                 => ['us-west-1', 'us-west-2'],
                  'bucket_prefix'           => 'prefix',
                  'simpledb'               => true,
                  'authorized_aws_accounts' => [ 'test1 @acct.com', 'test2@acct.com' ]
                }
              }
  end

  it "should create a new config object from the hash passed as config" do
    config = Heirloom::Config.new :config => @config,
                                  :logger => 'da-logger'
    config.access_key.should == @config['aws']['access_key']
    config.secret_key.should == @config['aws']['secret_key']
    config.regions.should == @config['aws']['regions']
    config.primary_region.should == 'us-west-1'
    config.bucket_prefix.should == @config['aws']['bucket_prefix']
    config.authorized_aws_accounts.should == @config['aws']['authorized_aws_accounts']
    config.simpledb.should == true
    config.logger.should == 'da-logger'
  end

  it "should create a new config object and read from ~/.heirloom.yml" do
    File.should_receive(:open).with("#{ENV['HOME']}/.heirloom.yml").
                               and_return(@config.to_yaml)
    config = Heirloom::Config.new
    config.access_key.should == @config['aws']['access_key']
    config.secret_key.should == @config['aws']['secret_key']
    config.regions.should == @config['aws']['regions']
    config.primary_region.should == 'us-west-1'
    config.bucket_prefix.should == @config['aws']['bucket_prefix']
    config.simpledb.should == true
    config.authorized_aws_accounts.should == @config['aws']['authorized_aws_accounts']
  end

  it "should set simpledb to true by default" do
    @config['aws']['simpledb'] = nil
    File.should_receive(:open).with("#{ENV['HOME']}/.heirloom.yml").
                               and_return(@config.to_yaml)
    config = Heirloom::Config.new
    config.simpledb.should == true
  end

end
