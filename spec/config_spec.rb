require 'spec_helper'

describe Heirloom do

  before do
    @config = { 'aws' => 
                { 'access_key'              => 'key',
                  'secret_key'              => 'secret',
                  'regions'                 => ['us-west-1', 'us-west-2'],
                  'bucket_prefix'           => 'prefix',
                  'authorized_aws_accounts' => [ 'test1 @acct.com', 'test2@acct.com' ]
                },
                'logger' => 'da-logger'
              }
  end

  it "should create a new config object from the hash passed as config" do
    config = Heirloom::Config.new :config => @config
    config.access_key.should == @config['aws']['access_key']
    config.secret_key.should == @config['aws']['secret_key']
    config.regions.should == @config['aws']['regions']
    config.primary_region.should == 'us-west-1'
    config.bucket_prefix.should == @config['aws']['bucket_prefix']
    config.authorized_aws_accounts.should == @config['aws']['authorized_aws_accounts']
    config.logger.should == @config['logger']
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
    config.authorized_aws_accounts.should == @config['aws']['authorized_aws_accounts']
  end

end
