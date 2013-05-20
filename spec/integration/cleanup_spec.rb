require 'spec_helper'
require 'macaddr'
require 'heirloom/cli'
require 'heirloom/logger'

describe "cleanup", :vcr => true, :integration => true do

  before do
    @bucket_prefix = "heirloom-integration-tests-#{Mac.addr.gsub(':', '')}"
    @name          = "integration_tests"

    Heirloom.stub :log => mock_log
    # Heirloom::HeirloomLogger.stub :new => mock_log

    # we want to load our own config
    Heirloom::CLI::Cleanup.any_instance.stub :load_settings! => true
    Heirloom.load_config! :config_file => "#{ENV['HOME']}/.heirloom.yml", :environment => "integration"
  end

  it "should require name" do

    Heirloom.log.should_receive(:error)
      .with("Option 'name' required but not specified")

    expect {
      Heirloom::CLI::Cleanup.new.cleanup
    }.to raise_error SystemExit

  end

end
