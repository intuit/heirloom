require 'spec_helper'

require 'heirloom/cli'

describe Heirloom do

  context "testing valid_options?" do

    before do
      @logger_mock = mock 'logger' 
      @object = Object.new
      @object.extend Heirloom::CLI::Shared
    end

    it "should return false if a required array is emtpy" do
      @logger_mock.should_receive(:error)
      @object.valid_options?(:provided => { :array  => [],
                                            :string => 'present' },
                             :required => [:array, :string],
                             :logger   => @logger_mock).should be_false
    end

    it "should return false if a required string is nil" do
      @logger_mock.should_receive(:error)
      @object.valid_options?(:provided => { :array  => ['present'],
                                            :string => nil },
                             :required => [:array, :string],
                             :logger   => @logger_mock).should be_false
    end

    it "should return false if a require string is nil & array is empty" do
      @logger_mock.should_receive(:error).exactly(2).times
      @object.valid_options?(:provided => { :array  => [],
                                            :string => nil },
                             :required => [:array, :string],
                             :logger   => @logger_mock).should be_false
    end

    it "should return true if all options are present" do
      @logger_mock.should_receive(:error).exactly(0).times
      @object.valid_options?(:provided => { :array  => ['present'],
                                            :string => 'present' },
                             :required => [:array, :string],
                             :logger   => @logger_mock).should be_true
    end
  end

  context "testing load_config" do

    before do
      @config_mock = mock 'config'
      @logger_mock = mock 'logger'
      @object = Object.new
      @object.extend Heirloom::CLI::Shared
      Heirloom::Config.should_receive(:new).with(:logger => @logger_mock).
                       and_return @config_mock
    end

    it "should return the configuration" do
      @object.load_config(:logger => @logger_mock,
                          :opts => {}).should == @config_mock
    end

    it "should set the access key if specified" do
      opts = { :key       => 'the_key',
               :key_given => true }
      @config_mock.should_receive(:access_key=).with 'the_key'
      @object.load_config :logger => @logger_mock, :opts => opts
    end

    it "should set the secret key if specified" do
      opts = { :secret       => 'the_secret',
               :secret_given => true }
      @config_mock.should_receive(:secret_key=).with 'the_secret'
      @object.load_config :logger => @logger_mock, :opts => opts
    end
  end

end
