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
      lambda { @object.ensure_path_is_directory(:path => '/tmp/test',
                                                :config => @config_mock) }.
                       should raise_error SystemExit
    end

    it "should not exit when path is a directory" do
      File.should_receive(:directory?).with('/tmp/test').
                                       and_return true
      @object.ensure_path_is_directory :path => '/tmp/test', :config => @config_mock
    end

    it "should exit when directory is not writable" do
      File.should_receive(:writable?).with('/tmp/test').
                                       and_return false
      lambda { @object.ensure_directory_is_writable(:path => '/tmp/test',
                                                    :config => @config_mock) }.
                       should raise_error SystemExit
    end

    it "should not exit when directory is writable" do
      File.should_receive(:writable?).with('/tmp/test').
                                       and_return true
      @object.ensure_directory_is_writable :path => '/tmp/test', :config => @config_mock
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

    it "should exit if the domain does not exist" do
      @archive_mock.stub :domain_exists? => false
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

    it "should exit if the archive does not exist" do
      @archive_mock.should_receive(:exists?).and_return false
      options = { :config => @config_stub, :archive => @archive_mock }
      lambda { @object.ensure_archive_exists options }.
                       should raise_error SystemExit
    end
  end

  context "testing ensure archive domain empty" do
    before do
      @archive_stub = stub 'archive'
      @logger_stub = stub 'logger', :error => true
      @config_stub = stub 'config', :logger          => @logger_stub,
                                    :metadata_region => 'us-west-1'
      @options = { :config => @config_stub, :archive => @archive_stub }
      @object = Object.new
      @object.extend Heirloom::CLI::Shared
    end

    it "should exit if the domain is not empty" do
      @archive_stub.stub :count => 200
      lambda { @object.ensure_archive_domain_empty @options }.
                       should raise_error SystemExit
    end
  end

  context "testing ensure catalog domain exists" do
    before do
      @catalog_mock = mock 'catalog'
      @logger_stub = stub 'logger', :error => true
      @config_stub = stub 'config', :logger          => @logger_stub,
                                    :metadata_region => 'us-west-1'
      @options = { :config => @config_stub, :catalog => @catalog_mock }
      @object = Object.new
      @object.extend Heirloom::CLI::Shared
    end

    it "should exit if the catlog domain does not exist" do
      @catalog_mock.stub :catalog_domain_exists? => false
      lambda { @object.ensure_catalog_domain_exists @options }.
                       should raise_error SystemExit
    end
  end

  context "testing ensure entry (does not) exists in catalog" do
    before do
      @catalog_mock = mock 'catalog'
      @logger_stub = stub 'logger', :error => true
      @config_stub = stub 'config', :logger          => @logger_stub,
                                    :metadata_region => 'us-west-1'
      @options = { :config  => @config_stub,
                   :catalog => @catalog_mock,
                   :entry   => 'entry' }
      @object = Object.new
      @object.extend Heirloom::CLI::Shared
    end

    it "should exit if the entry does not exist in catalog" do
      @catalog_mock.should_receive(:entry_exists_in_catalog?).
                    with('entry').
                    and_return false
      lambda { @object.ensure_entry_exists_in_catalog @options }.
                       should raise_error SystemExit
    end

  end

  context "testing latest id" do
    before do
      @archive_mock = mock 'archive'
      @config_stub = stub 'config'
      @options = { :config => @config_stub, :archive => @archive_stub }
      @object = Object.new
      @object.extend Heirloom::CLI::Shared
    end

    it "should return the latest id" do
      Heirloom::Archive.should_receive(:new).
                        with(:name => 'test',
                             :config => @config_stub).
                        and_return @archive_mock
      @archive_mock.should_receive(:list).
                    with(1).
                    and_return ['id']
      @object.latest_id(:name   => 'test',
                        :config => @config_stub).
              should == 'id'
    end

  end

  context "read secret from file" do
    before do
      @archive_mock = mock 'archive'
      @logger_stub = stub 'logger', :error => true
      @config_stub = stub 'config', :logger => @logger_stub
      @options = { :config => @config_stub, :opts => {} }
      @object = Object.new
      @object.extend Heirloom::CLI::Shared
    end

    it "should exit if the file does not exist" do
      @options[:opts][:secret_file] = '/bad/file'
      File.stub :exists? => false
      lambda { @object.read_secret @options }.
                       should raise_error SystemExit
    end

    it "should return the contents of the file with newline removed" do
      file_mock = mock 'file'
      @options[:opts][:secret_file] = '/good/file'
      File.stub :exists? => true
      File.should_receive(:read).
           with('/good/file').
           and_return "the-password\n"
      @object.read_secret(@options).
              should == 'the-password'
    end

    it "should return the password specified as secret" do
      @options[:opts][:secret] = 'the-password'
      @object.read_secret(@options).should == 'the-password'
    end

  end

  context "ensure buckets are available or owned by account" do
    before do
      @logger_stub  = stub 'logger', :error => true
      @config_stub  = stub 'config', :logger => @logger_stub
      @checker_mock = mock 'checker'
      @args = { :config        => @config_stub,
                :bucket_prefix => 'intu-lc',
                :regions       => ['us-west-1', 'us-west-2'] }
      @object = Object.new
      @object.extend Heirloom::CLI::Shared
      Heirloom::Checker.should_receive(:new).
                        with(:config => @config_stub).
                        and_return @checker_mock
    end

    it "should return true if buckets available in all regions" do
      @checker_mock.should_receive(:bucket_name_available?).
                    with(:bucket_prefix => 'intu-lc',
                         :regions       => ['us-west-1', 'us-west-2'],
                         :config        => @config_stub).
                    and_return true
      @object.ensure_buckets_available(@args).should be_true
    end

    it "should return raise and error if any bucket un-available in all regions" do
      @checker_mock.should_receive(:bucket_name_available?).
                    with(:bucket_prefix => 'intu-lc',
                         :regions       => ['us-west-1', 'us-west-2'],
                         :config        => @config_stub).
                    and_return false
      lambda { @object.ensure_buckets_available(@args) }.
               should raise_error SystemExit
    end
  end

  context "testing ensure entry does not exist in catalog unless forced" do
    before do
      @catalog_mock = mock 'catalog'
      @logger_stub = stub 'logger', :error => true
      @config_stub = stub 'config', :logger          => @logger_stub,
                                    :metadata_region => 'us-west-1'
      @object = Object.new
      @object.extend Heirloom::CLI::Shared
    end

    it "should exit if the entry exists in catalog and not forced" do
      options = { :config  => @config_stub,
                  :catalog => @catalog_mock,
                  :entry   => 'entry',
                  :force   => false }
      @catalog_mock.should_receive(:entry_exists_in_catalog?).
                    with('entry').
                    and_return true
      lambda { @object.ensure_entry_does_not_exist_in_catalog options }.
                       should raise_error SystemExit
    end

    it "should not exit if the entry exists in catalog and forced" do
      options = { :config  => @config_stub,
                  :catalog => @catalog_mock,
                  :entry   => 'entry',
                  :force   => true }
      @catalog_mock.should_receive(:entry_exists_in_catalog?).
                    with('entry').
                    and_return true
      @object.ensure_entry_does_not_exist_in_catalog options
    end

    it "should not exit if the does not exists in catalog" do
      options = { :config  => @config_stub,
                  :catalog => @catalog_mock,
                  :entry   => 'entry',
                  :force   => false }
      @catalog_mock.should_receive(:entry_exists_in_catalog?).
                    with('entry').
                    and_return false
      @object.ensure_entry_does_not_exist_in_catalog options
    end
  end

  context "testing ensure valid name" do
    before do
      @logger_stub = stub 'logger', :error => true
      @config_stub = stub 'config', :logger          => @logger_stub,
                                    :metadata_region => 'us-west-1'
      @object = Object.new
      @object.extend Heirloom::CLI::Shared
    end

    it "should not exit if name is valid" do
      @object.ensure_valid_name :config => @config_stub,
                                :name   => 'test-123_test'
    end

    it "should exit if name contains a upper case" do
      lambda { @object.ensure_valid_name :config => @config_stub,
                                         :name   => 'TEST-123' }.
                       should raise_error SystemExit
    end

    it "should exit if name contains a space" do
      lambda { @object.ensure_valid_name :config => @config_stub,
                                         :name   => 'test 123' }.
                       should raise_error SystemExit
    end

    it "should exit if name contains invalid characters" do
      lambda { @object.ensure_valid_name :config => @config_stub,
                                         :name   => 'test,123' }.
                       should raise_error SystemExit
    end
  end

  context "testing ensure valid bucket prefix" do
    before do
      @logger_stub = stub 'logger', :error => true
      @config_stub = stub 'config', :logger          => @logger_stub,
                                    :metadata_region => 'us-west-1'
      @object = Object.new
      @object.extend Heirloom::CLI::Shared
    end

    it "should not exit if bucket_prefix is valid" do
      @object.ensure_valid_bucket_prefix :config        => @config_stub,
                                         :bucket_prefix => 'test-123'
    end

    it "should exit if bucket_prefix contains uppercase" do
      lambda { @object.ensure_valid_bucket_prefix :config        => @config_stub,
                                                  :bucket_prefix => 'TEST-123' }.
                       should raise_error SystemExit
    end

    it "should exit if bucket_prefix contains a space" do
      lambda { @object.ensure_valid_bucket_prefix :config        => @config_stub,
                                                  :bucket_prefix => 'test 123' }.
                       should raise_error SystemExit
    end

    it "should exit if bucket_prefix contains invalid characters" do
      lambda { @object.ensure_valid_bucket_prefix :config        => @config_stub,
                                                  :bucket_prefix => 'test,123' }.
                       should raise_error SystemExit
    end
  end
end
