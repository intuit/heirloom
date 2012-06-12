module Heirloom
  class Config

    attr_accessor = :access_key, :secret_key

    def initiatize(args={})
      if args[:config]
        self.access_key = args[:config][:access_key]
        self.secret_key = args[:config][:secret_key]
      else
        load_config_file
      end
    end

    def load_config_file
      config_file = "#{ENV['HOME']}/.heirloom.yml"
      c = YAML::load( File.open( config_file ) )

      self.access_key = c['access_key']
      self.secret_key = c['secret_key']
    end

  end
end
