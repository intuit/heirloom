require 'hashie'

include Hashie

module GlobalConfig

  attr_accessor :global_config_defaults, :global_config_file

  def config
    @config ||= Mash.new
  end

  def load_config(options = {})
    config_file = options[:config_file] || global_config_file
    env         = options[:environment] || 'default'

    config.merge! global_config_defaults

    config.merge! load_config_file(config_file, env)

    config.merge! options
  end

  private

  def load_config_file(config_file, env)
    config_from_file = {}

    if config_file and File.exists? config_file
      fsettings = Mash.new YAML::load_file config_file
      if fsettings.has_key? env
        config_from_file = fsettings[env]
      else
        raise ArgumentError, "#{env} environment not found in #{config_file}"
      end
    end

    config_from_file
  end

end
