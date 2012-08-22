module Heirloom
  module CLI
    module Shared

      def load_config(args)
        opts = args[:opts]
        logger = args[:logger]
        config = Config.new :logger => logger
        config.access_key = opts[:aws_access_key] if opts[:aws_access_key_given]
        config.secret_key = opts[:aws_secret_key] if opts[:aws_secret_key_given]
        config.metadata_region = opts[:metadata] if opts[:metadata_given]
        config
      end

      def ensure_valid_secret(args)
        config = args[:config]
        secret = args[:secret]
        logger = config.logger
        if secret && secret.length < 8
          logger.error "Secret must be at least 8 characters long."
          exit 1
        end
      end

      def ensure_valid_options(args)
        provided = args[:provided]
        required = args[:required]
        config   = args[:config]
        logger   = config.logger

        required << :aws_access_key unless config.access_key
        required << :aws_secret_key unless config.secret_key
        required << :metadata unless config.metadata

        missing_opts = required.sort.map do |opt|
          case provided[opt]
          when nil, []
            pretty_opt = opt.to_s.gsub('_', '-')
            "Option '#{pretty_opt}' required but not specified."
          end
        end

        missing_opts.compact!

        missing_opts.each {|missing_opt| logger.error missing_opt}

        exit 1 unless missing_opts.empty?
      end

      def ensure_directory(args)
        config = args[:config]
        path = args[:path]
        logger = config.logger

        unless File.directory? path
          logger.error "#{path} is not a directory."
          exit 1
        end
      end

      def ensure_domain_exists(args)
        config = args[:config]
        name = args[:name]
        logger = config.logger

        archive = Archive.new :name   => name,
                              :config => config

        unless archive.domain_exists?
          logger.error "Heirloom domain does not exist."
          exit 1
        end
      end

    end
  end
end
