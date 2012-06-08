module Heirloom
  class Config
    def self.load_config_file(config_file = "#{ENV['HOME']}/.heirloom.yml")
      YAML::load( File.open( config_file ) )
    end

    def self.access_key
      load_config_file['access_key']
    end

    def self.secret_key
      load_config_file['secret_key']
    end
  end
end
