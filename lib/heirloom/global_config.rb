require 'hashie'

include Hashie

module Heirloom
  module GlobalConfig

    def self.included(base)
      base.extend(self)
    end

    attr_writer :config_defaults, :config_file

    def config
      load_config! if @config.nil?
      @config
    end

    def config_defaults
      @config_defaults || { 
        :logger          => Heirloom.log,
        :log_level       => 'info',
        :metadata_region => 'us-west-1'
      }
    end
    
    def config_file
      @config_file || "#{ENV['HOME']}/.heirloom.yml"
    end

    def load_config!(options = {})
      cfile = options[:config_file] || config_file
      env   = options[:environment] || 'default'

      @config = Mash.new config_defaults

      @config.merge! load_config_file(cfile, env)

      # don't copy over nils since trollop passes nil when option not specified
      @config.merge!(options) do |k, old, new|
        new.nil? ? old : new
      end
    end

    private

    def load_config_file(config_file, env)
      config = {}

      if config_file and File.exists? config_file
        fsettings = Mash.new YAML::load_file config_file
        if fsettings.has_key? env
          config = fsettings[env]
        else
          raise ArgumentError, "#{env} environment not found in #{config_file}"
        end
      end

      config
    end
  end
end
