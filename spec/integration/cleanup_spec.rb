require 'spec_helper'
require 'macaddr'
require 'heirloom/cli'
require 'heirloom/logger'

describe "cleanup", :integration => true do

  def wait_for_aws(num_seconds = 5)
    sleep num_seconds
  end

  def create_temp_heirloom_content
    tmp_dir = Dir.mktmpdir
    File.open(File.join(tmp_dir, 'index.html'), 'w') do |f|
      f.write 'Hello World!'
    end
    tmp_dir
  end

  def reset_config(opts = {})
    # only access_key and secret_key are required in ~/.heirloom.yml for integration testing
    defaults = {
      :config_file     => "#{ENV['HOME']}/.heirloom.yml", 
      :environment     => 'integration',
      :region          => ['us-west-1'],
      :metadata_region => 'us-west-1',
      :level           => 'debug'
    }

    Heirloom.load_config!(opts.merge(defaults))
    Heirloom.config.stub :logger => mock_log
    Trollop.stub :options => Heirloom.config
  end

  before do
    @bucket_prefix = "heirloom-integration-tests-#{Mac.addr.gsub(':', '')}"
    @name          = "integration_tests"
    @domain        = "heirloom_#{@name}"

    Heirloom.stub :log => mock_log
    # Heirloom::HeirloomLogger.stub :new => mock_log

    # we want to load our own config
    Heirloom::CLI::Cleanup.any_instance.stub :load_settings! => true
    Heirloom.load_config! :config_file => "#{ENV['HOME']}/.heirloom.yml", :environment => "integration"

    reset_config
  end

  it "should require name" do

    Heirloom.log.should_receive(:error)
      .with("Option 'name' required but not specified")

    expect {
      Heirloom::CLI::Cleanup.new.cleanup
    }.to raise_error SystemExit

  end

  context "setting up and tearing down" do

    before do
      @tmp_dir = create_temp_heirloom_content

      reset_config(
        :name            => @name,
        :bucket_prefix   => @bucket_prefix
      )

      Heirloom::CLI::Setup.new.setup
      # give the bucket a chance to propagate
      wait_for_aws

      @sdb = Heirloom::AWS::SimpleDB.new :config => Heirloom.config
    end
    
    after do
      reset_config(
        :name  => @name,
        :force => true
      )
      Heirloom::CLI::Teardown.new.teardown
      FileUtils.remove_entry @tmp_dir
    end

    it "should delete some number of archives from an heirloom" do
      (1..3).each do |i|
        reset_config(
          :id        => "v#{i}",
          :name      => @name,
          :directory => @tmp_dir
        )
        Heirloom::CLI::Upload.new.upload
      end

      reset_config(
        :name => @name,
        :keep => 2
      )
      Heirloom::CLI::Cleanup.new.cleanup
      wait_for_aws

      @sdb.count(@domain).should == 2
    end

  end

end
