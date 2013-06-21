require 'spec_helper'

describe Heirloom do

  before do
    @config_file = { 'default' => 
                     { 'access_key'      => 'key',
                       'secret_key'      => 'secret',
                       'metadata_region' => 'us-west-2'
                     },
                     'dev' =>
                     { 'access_key'      => 'devkey',
                       'secret_key'      => 'devsecret',
                       'metadata_region' => 'devmd'
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
    config.access_key.should == @config_file['default']['access_key']
    config.secret_key.should == @config_file['default']['secret_key']
    config.metadata_region.should == @config_file['default']['metadata_region']
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

  it "should load a different environment if requested" do
    File.stub :exists? => true
    File.should_receive(:open).with("#{ENV['HOME']}/.heirloom.yml").
                               and_return(@config_file.to_yaml)
    config = Heirloom::Config.new :environment => 'dev'
    config.access_key.should == @config_file['dev']['access_key']
    config.secret_key.should == @config_file['dev']['secret_key']
    config.metadata_region.should == @config_file['dev']['metadata_region']
  end

  it "should still allow overrides with different environments" do
    File.stub :exists? => true
    File.should_receive(:open).with("#{ENV['HOME']}/.heirloom.yml").
                               and_return(@config_file.to_yaml)
    opts = {
      :aws_access_key => 'specialdevkey'
    }

    config = Heirloom::Config.new :opts => opts, :environment => 'dev'
    config.access_key.should == 'specialdevkey'
    config.metadata_region.should == @config_file['dev']['metadata_region']
  end

  it "should log a warning if a non-existing environment is requested from existing config file" do
    File.stub :exists? => true
    File.should_receive(:open).with("#{ENV['HOME']}/.heirloom.yml").
                               and_return(@config_file.to_yaml)
    logger_mock = mock 'logger'
    logger_mock.should_receive(:warn)

    lambda {
      config = Heirloom::Config.new :environment => 'missing', :logger => logger_mock
    }.should_not raise_error SystemExit
  end

end
