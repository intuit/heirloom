require 'spec_helper'
require 'heirloom/cli'
require 'heirloom/logger'

describe "authorize", :integration => true do
  
  before do
    @bucket_prefix = ENV['HEIRLOOM_INTEGRATION_BUCKET_PREFIX']
    @name          = @bucket_prefix
    @domain        = "heirloom_#{@name}"
  end

  it "should require accounts, id, and name" do
    reset_env

    @output = capture(:stdout) do

      expect {
        Heirloom::CLI::Authorize.new.authorize
      }.to raise_error SystemExit

    end
    
    @output.should =~ /Option 'accounts' required but not specified./
    @output.should =~ /Option 'id' required but not specified./
    @output.should =~ /Option 'name' required but not specified./
  end

  context "performing authorization of non-existent account" do
    
    before do
      @tmp_dir = create_temp_heirloom_content
      reset_env(
        :bucket_prefix   => @bucket_prefix,
        :force           => true,
        :metadata_region => 'us-west-1',
        :name            => @name,
        :region          => ['us-west-1']
      )
      Heirloom::CLI::Setup.new.setup
      # give the bucket a chance to propagate
      wait_for_aws
      
      reset_env(
        :name      => @name,
        :id        => "v1",
        :directory => @tmp_dir
      )
      Heirloom::CLI::Upload.new.upload
    end

    after do
      reset_env(
        :name => @name,
        :force => true,
        :keep_buckets => true
      )
      Heirloom::CLI::Teardown.new.teardown
      FileUtils.remove_entry @tmp_dir
    end

    it "should try to authorize but fail" do
      reset_env(
        :name     => @name,
        :id       => "v1",
        :accounts => ["X" * 64]
      )
      expect {
        Heirloom::CLI::Authorize.new.authorize
      }.to raise_error(Excon::Errors::BadRequest) { |err|
        err.response.status.should == 400
        err.response.body.should =~ /InvalidArgument/
        err.response.body.should =~ /Invalid id/
      }
    end

  end

end
