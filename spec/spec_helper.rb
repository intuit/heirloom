require 'simplecov'

SimpleCov.start do
  add_filter '/spec'
end if ENV["COVERAGE"]

require 'rubygems'
require 'bundler/setup'

require 'heirloom'

module SpecHelpers

  def mock_config(args={})
    args[:logger]          ||= stub :debug => true, :info => true, :warn => true, :error => true
    args[:access_key]      ||= 'key'
    args[:secret_key]      ||= 'secret'
    args[:metadata_region] ||= 'us-west-1'
    args[:use_iam_profile] ||= false

    config_mock = mock 'config'
    config_mock.stub args

    config_mock
  end

end

RSpec.configure do |config|
  config.include SpecHelpers
end

