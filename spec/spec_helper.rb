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
RUN_INTEGRATION_TESTS = HEIRLOOM_INT_BP && !HEIRLOOM_INT_BP.empty?

module SpecHelpers

  def set_env_var(name,value)
    ENV.stub(:fetch).with(name, nil).and_return(value)
  end

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

end

module IntegrationHelpers
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
    opts[:environment]     = 'integration'
    opts[:log_level]       = 'debug'
    opts[:metadata_region] = 'us-west-1'

    Trollop.stub :options => opts
  end

  def capture(*streams)
    streams.map! { |stream| stream.to_s }
    begin
      result = StringIO.new
      streams.each { |stream| eval "$#{stream} = result" }
      yield
    ensure
      streams.each { |stream| eval "$#{stream} = #{stream.upcase}" }
    end
    result.string
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
  config.include IntegrationHelpers

  # https://www.relishapp.com/vcr/vcr/v/2-4-0/docs/test-frameworks/usage-with-rspec-metadata!
  config.treat_symbols_as_metadata_keys_with_true_values = true

  config.filter_run_excluding :integration => true unless ENV['HEIRLOOM_INTEGRATION_BUCKET_PREFIX']
end

