module Heirloom
  class Config

    attr_accessor :access_key, :secret_key, :primary_region, :logger

    def initialize(args = {})
      @config = args[:config]
      self.logger = args[:logger] ||= HeirloomLogger.new
      load_config_file
    end

    def load_config_file
      config_file = "#{ENV['HOME']}/.heirloom.yml"
      config = @config ? @config : YAML::load(File.open(config_file))

      aws = config['aws']

      self.access_key = aws['access_key']
      self.secret_key = aws['secret_key']
      self.primary_region = aws['primary_region'] ||= 'us-west-1'
    end

  end
end
