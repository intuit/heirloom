require 'spec_helper'

describe Heirloom do

  before do
    @config = { 'aws' => 
                { 'access_key '     => 'key',
                  'secret_key '     => 'secret',
                  'metadata_region' => 'us-west-2'
                }
              }
  end

  it "should create a new config object from the hash passed as config" do
    config = Heirloom::Config.new :config => @config,
                                  :logger => 'da-logger'
    config.access_key.should == @config['aws']['access_key']
    config.secret_key.should == @config['aws']['secret_key']
    config.metadata_region.should == @config['aws']['metadata_region']
    config.logger.should == 'da-logger'
  end

  it "should create a new config object and read from ~/.heirloom.yml" do
    File.stub :exists? => true
    File.should_receive(:open).with("#{ENV['HOME']}/.heirloom.yml").
                               and_return(@config.to_yaml)
    config = Heirloom::Config.new
    config.access_key.should == @config['aws']['access_key']
    config.secret_key.should == @config['aws']['secret_key']
    config.metadata_region.should == @config['aws']['metadata_region']
  end

  it "should return nil if metadata_region not present in config" do
    @config['aws'] = {}
    config = Heirloom::Config.new :config => @config,
                                  :logger => 'da-logger'
    config.metadata_region.should == nil
  end

  it "should load a blank config if the file does not exist and no config passed" do
    File.stub :exists? => false
    config = Heirloom::Config.new
    config.access_key.should be_nil
    config.secret_key.should be_nil
    config.metadata_region.should be_nil
  end

end
