require 'spec_helper'

describe Heirloom do

  before do
    @config = { 'aws' => 
                { 'access_key'     => 'key',
                  'secret_key'     => 'secret',
                  'primary_region' => 'us-west-2'
                }
              }
  end

  it "should create a new config object from the hash passed as config" do
    config = Heirloom::Config.new :config => @config,
                                  :logger => 'da-logger'
    config.access_key.should == @config['aws']['access_key']
    config.secret_key.should == @config['aws']['secret_key']
    config.primary_region.should == @config['aws']['primary_region']
    config.logger.should == 'da-logger'
  end

  it "should create a new config object and read from ~/.heirloom.yml" do
    File.should_receive(:open).with("#{ENV['HOME']}/.heirloom.yml").
                               and_return(@config.to_yaml)
    config = Heirloom::Config.new
    config.access_key.should == @config['aws']['access_key']
    config.secret_key.should == @config['aws']['secret_key']
    config.primary_region.should == @config['aws']['primary_region']
  end

  it "should set the primary region to us-west-1 if not present in config" do
    @config['aws'] = {}
    config = Heirloom::Config.new :config => @config,
                                  :logger => 'da-logger'
    config.primary_region.should == 'us-west-1'
  end


end
