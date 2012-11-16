require 'spec_helper'

describe Heirloom do

  before do
    @config_file = { 'aws' => 
                     { 'access_key'      => 'key',
                       'secret_key'      => 'secret',
                       'metadata_region' => 'us-west-2'
                     }
                   }
    @opts = { :aws_access_key  => 'optkey',
              :aws_secret_key  => 'optsec',
              :metadata_region => 'optmd' }
                 
  end

  it "should create a new config object from the hash passed as config" do
    File.stub :exists? => false
    File.should_receive(:open).never
    config = Heirloom::Config.new :opts   => @opts,
                                  :logger => 'da-logger'
    config.access_key.should == @opts[:aws_access_key]
    config.secret_key.should == @opts[:aws_secret_key]
    config.metadata_region.should == @opts[:metadata_region]
    config.logger.should == 'da-logger'
  end

  it "should create a new config object and read from ~/.heirloom.yml" do
    File.stub :exists? => true
    File.should_receive(:open).with("#{ENV['HOME']}/.heirloom.yml").
                               and_return(@config_file.to_yaml)
    config = Heirloom::Config.new
    config.access_key.should == @config_file['aws']['access_key']
    config.secret_key.should == @config_file['aws']['secret_key']
    config.metadata_region.should == @config_file['aws']['metadata_region']
  end
  
  it "should override config settings in file from opts" do
    File.stub :exists? => true
    File.should_receive(:open).with("#{ENV['HOME']}/.heirloom.yml").
                               and_return(@config_file.to_yaml)
    config = Heirloom::Config.new :opts => @opts
    config.access_key.should == @opts[:aws_access_key]
    config.secret_key.should == @opts[:aws_secret_key]
    config.metadata_region.should == @opts[:metadata_region]
  end

  it "should load a blank config if the file does not exist and no config passed" do
    File.stub :exists? => false
    config = Heirloom::Config.new
    config.access_key.should be_nil
    config.secret_key.should be_nil
    config.metadata_region.should be_nil
  end

end
