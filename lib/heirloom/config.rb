module Heirloom
  class Config

    attr_accessor :access_key, :secret_key, :metadata_region, :logger, :environment, :use_iam_profile

    def initialize(args={})
      @opts        = args[:opts] ||= Hash.new
      @logger      = args[:logger] ||= HeirloomLogger.new
      @environment = args[:environment] ||= 'default'
      @config      = load_config_file
      load_config
    end

    def load_config
      @access_key      = @opts.fetch :aws_access_key,
                                     @config['access_key']
      @secret_key      = @opts.fetch :aws_secret_key,
                                     @config['secret_key']
      @metadata_region = @opts.fetch :metadata_region,
                                     @config['metadata_region']
      @use_iam_profile = @opts.fetch :use_iam_profile,
                                     false
    end

    def proxy
      @proxy ||= env.load 'https_proxy'
    end

    private

    def load_config_file
      if File.exists? config_file
        data = YAML::load File.open(config_file)
        if data && data.has_key?(@environment)
          return data[@environment]
        else
          @logger.warn "Environment '#{@environment}' not found in config file."
        end
      end
      {}
    end

    def config_file
     @config_file ||= env_config_file || default_config_file
    end

    def env_config_file
      env.load 'HEIRLOOM_CONFIG_FILE'
    end

    def default_config_file
      "#{env.load 'HOME'}/.heirloom.yml"
    end

    def env
      @env ||= Env.new
    end

  end
end
