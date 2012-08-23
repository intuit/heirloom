require 'spec_helper'

require 'heirloom/cli'

describe Heirloom do

  context "testing ensure_valid_options" do

    before do
      @config_mock = mock 'config'
      @logger_mock = mock 'logger' 
      @config_mock.stub :logger          => @logger_mock, 
                        :access_key      => 'key',
                        :secret_key      => 'secret',
                        :metadata_region => 'us-west-1'
      @object = Object.new
      @object.extend Heirloom::CLI::Shared
    end

    it "should exit if the secret is given and under 8 characters" do
      @logger_mock.should_receive(:error)
      @logger_mock.stub :info => true
      lambda { @object.ensure_valid_secret(:secret => 'shorty',
                                           :config => @config_mock) }.
                       should raise_error SystemExit
    end

    it "should return false if a required array is emtpy" do
      @logger_mock.should_receive(:error)
      lambda { @object.ensure_valid_options(:provided => { 
                                              :array  => [],
                                              :string => 'present' 
                                            },
                                            :required => [:array, :string],
                                            :config   => @config_mock) }.
                       should raise_error SystemExit
    end

    it "should return false if a required string is nil" do
      @logger_mock.should_receive(:error)
      lambda { @object.ensure_valid_options(:provided => { 
                                              :array  => ['present'],
                                              :string => nil 
                                            },
                                            :required => [:array, :string],
                                            :config   => @config_mock) }.
                       should raise_error SystemExit
    end

    it "should return false if a require string is nil & array is empty" do
      @logger_mock.should_receive(:error).exactly(2).times
      lambda { @object.ensure_valid_options(:provided => { 
                                              :array  => [],
                                              :string => nil 
                                            },
                                            :required => [:array, :string],
                                            :config   => @config_mock) }.
                       should raise_error SystemExit
    end

    it "should return true if all options are present" do
      @logger_mock.should_receive(:error).exactly(0).times
      @object.ensure_valid_options(:provided => { :array  => ['present'],
                                            :string => 'present' },
                             :required => [:array, :string],
                             :config   => @config_mock)
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

    it "should set the metadata region if specified" do
      opts = { :metadata_region => 'us-west-1' }
      @config_mock.should_receive(:metadata_region=).with 'us-west-1'
      @object.load_config :logger => @logger_mock, :opts => opts
    end

    it "should set the access key if specified" do
      opts = { :aws_access_key => 'the_key' }
      @config_mock.should_receive(:access_key=).with 'the_key'
      @object.load_config :logger => @logger_mock, :opts => opts
    end

    it "should set the secret key if specified" do
      opts = { :aws_secret_key => 'the_secret' }
      @config_mock.should_receive(:secret_key=).with 'the_secret'
      @object.load_config :logger => @logger_mock, :opts => opts
    end

  end

  context "test ensure directory" do
    before do
      @logger_stub = stub 'logger', :error => true
      @config_mock = mock 'config'
      @config_mock.stub :logger => @logger_stub
      @object = Object.new
      @object.extend Heirloom::CLI::Shared
    end

    it "should exit when path is not a directory" do
      File.should_receive(:directory?).with('/tmp/test').
                                       and_return false
      lambda { @object.ensure_directory(:path => '/tmp/test', 
                                        :config => @config_mock) }.
                       should raise_error SystemExit
    end

    it "should not exit when path is a directory" do
      File.should_receive(:directory?).with('/tmp/test').
                                       and_return true
      @object.ensure_directory :path => '/tmp/test', :config => @config_mock
    end

  end

  context "testing ensure domain" do
    before do
      @archive_mock = mock 'archive'
      @logger_stub = stub 'logger', :error => true
      @config_stub = stub 'config', :logger          => @logger_stub,
                                    :metadata_region => 'us-west-1'
      @object = Object.new
      @object.extend Heirloom::CLI::Shared
      Heirloom::Archive.should_receive(:new).
                        with(:name => 'test', :config => @config_stub).
                        and_return @archive_mock
    end

    it "should ensure the domain for a given archive exists" do
      @archive_mock.should_receive(:domain_exists?).and_return true
      @object.ensure_domain_exists :config => @config_stub, 
                                   :name   => 'test'
    end

    it "should exit if the domain does not exist" do
      @archive_mock.should_receive(:domain_exists?).and_return false
      lambda { @object.ensure_domain_exists :config => @config_stub,
                                            :name   => 'test'}.
                       should raise_error SystemExit
    end
  end

  context "testing ensure metadata domain" do
    before do
      @archive_mock = mock 'archive'
      @logger_stub = stub 'logger', :error => true
      @config_stub = stub 'config', :logger          => @logger_stub,
                                    :metadata_region => 'us-west-1'
      @object = Object.new
      @object.extend Heirloom::CLI::Shared
    end

    it "should ensure the metadata domain is included in the upload domains" do
      options = { :config => @config_stub, :regions => ['us-west-1', 'us-east-1'] }
      @object.ensure_metadata_in_upload_region options
    end

    it "should exit if the metadata region is not in an upload region" do
      options = { :config => @config_stub, :regions => ['us-west-2', 'us-east-1'] }
      lambda { @object.ensure_metadata_in_upload_region options }.
                       should raise_error SystemExit
    end
  end

  context "testing ensure valid regions" do
    before do
      @logger_stub = stub 'logger', :error => true
      @config_stub = stub 'config', :logger          => @logger_stub,
                                    :metadata_region => 'us-west-1'
      @object = Object.new
      @object.extend Heirloom::CLI::Shared
    end

    it "should ensure the metadata domain is included in the upload domains" do
      options = { :config => @config_stub, :regions => ['us-west-2', 'us-east-1'] }
      @object.ensure_valid_regions options
    end

    it "should exit if the region is not valid" do
      options = { :config => @config_stub, :regions => ['us-west-2', 'us-bad-1'] }
      lambda { @object.ensure_valid_regions options }.
                       should raise_error SystemExit
    end

  end

  context "testing ensure archive exists" do
    before do
      @archive_mock = mock 'archive'
      @logger_stub = stub 'logger', :error => true
      @config_stub = stub 'config', :logger          => @logger_stub,
                                    :metadata_region => 'us-west-1'
      @object = Object.new
      @object.extend Heirloom::CLI::Shared
    end

    it "should ensure the archive exists" do
      @archive_mock.should_receive(:exists?).and_return true
      options = { :config => @config_stub, :archive => @archive_mock }
      @object.ensure_archive_exists options
    end

    it "should exit if the archive does not exist" do
      @archive_mock.should_receive(:exists?).and_return false
      options = { :config => @config_stub, :archive => @archive_mock }
      lambda { @object.ensure_archive_exists options }.
                       should raise_error SystemExit
    end
  end


end
