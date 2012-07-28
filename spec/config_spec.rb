require 'spec_helper'

describe Heirloom do

  before do
    @config = { 'aws' => 
                { 'access_key'              => 'key',
                  'secret_key'              => 'secret'
                }
              }
  end

  it "should create a new config object from the hash passed as config" do
    config = Heirloom::Config.new :config => @config,
                                  :logger => 'da-logger'
    config.access_key.should == @config['aws']['access_key']
    config.secret_key.should == @config['aws']['secret_key']
    config.logger.should == 'da-logger'
  end

  it "should create a new config object and read from ~/.heirloom.yml" do
    File.should_receive(:open).with("#{ENV['HOME']}/.heirloom.yml").
                               and_return(@config.to_yaml)
    config = Heirloom::Config.new
    config.access_key.should == @config['aws']['access_key']
    config.secret_key.should == @config['aws']['secret_key']
  end

end
