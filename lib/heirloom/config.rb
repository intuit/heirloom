module Heirloom
  class Config

    attr_accessor :access_key, :secret_key, :primary_region, :logger

    def initialize(args = {})
      @config = args[:config] ? args[:config] : load_config_file
      self.logger = args[:logger] ||= HeirloomLogger.new
      load_config
    end

    def load_config
      aws = @config['aws']
      self.access_key = aws['access_key']
      self.secret_key = aws['secret_key']
      self.primary_region = aws['primary_region'] ||= 'us-west-1'
    end

    def load_config_file
      config_file = "#{ENV['HOME']}/.heirloom.yml"

      if File.exists? config_file
        YAML::load File.open(config_file)
      else
        { 'aws' => Hash.new }
      end
    end

  end
end
