module Heirloom
  class Config

    attr_accessor :access_key, :secret_key

    def initialize
      load_config_file
    end

    def load_config_file
      config_file = "#{ENV['HOME']}/.heirloom.yml"
      c = YAML::load( File.open( config_file ) )

      self.access_key = c['access_key']
      self.secret_key = c['secret_key']
    end

  end
end
