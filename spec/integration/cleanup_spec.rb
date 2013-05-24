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

  def reset_env(opts = {})
    opts[:environment] = 'integration'
    opts[:log_level]   = 'debug'

    Trollop.stub :options => opts
  end

  before do
    @bucket_prefix = "heirloom-integration-tests-#{Mac.addr.gsub(':', '')}"
    @name          = "integration_tests"
    @domain        = "heirloom_#{@name}"
  end

  it "should require name" do
    reset_env

    Heirloom.log.should_receive(:error)
      .with("Option 'name' required but not specified.")

    expect {
      Heirloom::CLI::Cleanup.new.cleanup
    }.to raise_error SystemExit

  end

  context "setting up and tearing down" do

    before do
      @tmp_dir = create_temp_heirloom_content

      reset_env(
        :bucket_prefix   => @bucket_prefix,
        :force           => true,
        :metadata_region => 'us-west-1',
        :name            => @name,
        :region          => ['us-east-1', 'us-west-1']
      )
      Heirloom::CLI::Setup.new.setup
      # give the bucket a chance to propagate
      wait_for_aws

      @sdb = Heirloom::AWS::SimpleDB.new :config => (Heirloom::Config.new :environment => 'integration')
    end
    
    after do
      reset_env(
        :name  => @name,
        :force => true
      )
      Heirloom::CLI::Teardown.new.teardown
      FileUtils.remove_entry @tmp_dir
    end

    it "should delete some number of archives from an heirloom" do
      (1..3).each do |i|
        reset_env(
          :id              => "v#{i}",
          :name            => @name,
          :directory       => @tmp_dir,
          :metadata_region => 'us-west-1'
        )
        Heirloom::CLI::Upload.new.upload
      end

      reset_env(
        :name => @name,
        :keep => 2
      )
      Heirloom::CLI::Cleanup.new.cleanup
      wait_for_aws

      @sdb.count(@domain).should == 2
    end

  end

end
