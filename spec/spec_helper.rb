require 'simplecov'

SimpleCov.start do
  add_filter '/spec'
end if ENV["COVERAGE"]

require 'hashie'
require 'rubygems'
require 'bundler/setup'
require 'vcr'

require 'heirloom'

HEIRLOOM_INT_BP = ENV['HEIRLOOM_INTEGRATION_BUCKET_PREFIX']
RUN_INTEGRATION_TESTS = !HEIRLOOM_INT_BP.nil? && !HEIRLOOM_INT_BP.empty?

module SpecHelpers

  def mock_log
    mock 'log', :debug => true, :info => true, :warn => true, :error => true, :level= => true
  end

  def mock_config(args = {})
    args[:logger]          ||= mock_log
    args[:access_key]      ||= 'key'
    args[:secret_key]      ||= 'secret'
    args[:metadata_region] ||= 'us-west-1'
    args[:use_iam_profile] ||= false

    Hashie::Mash.new args
  end

  def integration_or_mock_config
    if RUN_INTEGRATION_TESTS && File.exists?("#{ENV['HOME']}/.heirloom.yml")
      begin
        Heirloom::Config.new(:environment => 'integration', :logger => mock_log)
      rescue SystemExit
        mock_config
      end
    else
      mock_config
    end
  end

end

VCR.configure do |config|

  config.allow_http_connections_when_no_cassette = true
  config.cassette_library_dir = 'spec/fixtures/cassettes'
  config.hook_into :excon
  config.configure_rspec_metadata!

  if RUN_INTEGRATION_TESTS
    heirloom_integration_config = Heirloom::Config.new(:environment => 'integration')
    config.filter_sensitive_data('<AWSACCESSKEYID>') do
      heirloom_integration_config.access_key
    end
    config.filter_sensitive_data('<AWSSECRETKEY>') do
      heirloom_integration_config.secret_key
    end
  end

end

RSpec.configure do |config|
  config.include SpecHelpers

  # https://www.relishapp.com/vcr/vcr/v/2-4-0/docs/test-frameworks/usage-with-rspec-metadata!
  config.treat_symbols_as_metadata_keys_with_true_values = true

  config.filter_run_excluding :integration => true unless ENV['HEIRLOOM_INTEGRATION_BUCKET_PREFIX']
end

