require 'simplecov'

SimpleCov.start do
  add_filter '/spec'
end if ENV["COVERAGE"]

require 'hashie'
require 'rubygems'
require 'bundler/setup'

require 'heirloom'

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
    args[:proxy]           ||= nil

    Hashie::Mash.new args
  end

end

RSpec.configure do |config|
  config.include SpecHelpers
end

