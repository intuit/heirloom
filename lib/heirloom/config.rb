module Heirloom
  class Config

    attr_accessor :access_key, :secret_key, :metadata_region, :logger, :environment

    def initialize(args={})
      @opts        = args[:opts] ||= Hash.new
      @logger      = args[:logger] ||= HeirloomLogger.new
      @environment = args[:environment] ||= 'aws'
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
    end

    private

    def load_config_file
      config_file = "#{ENV['HOME']}/.heirloom.yml"

      if File.exists? config_file
        data = YAML::load File.open(config_file)
        if data.has_key? @environment
          data[@environment]
        else
          @logger.error "Environment '#{@environment}' not found in config file."
          exit 1
        end
      else
        { }
      end
    end

  end
end
