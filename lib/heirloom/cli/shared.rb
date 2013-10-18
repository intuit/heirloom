module Heirloom
  module CLI
    module Shared

      def load_config(args)
        opts = args[:opts]
        logger = args[:logger]
        config = Config.new :logger => logger, :environment => opts[:environment]
        config.access_key = opts[:aws_access_key] if opts[:aws_access_key]
        config.secret_key = opts[:aws_secret_key] if opts[:aws_secret_key]
        config.metadata_region = opts[:metadata_region] if opts[:metadata_region]
        config.use_iam_profile = opts[:use_iam_profile] if opts[:use_iam_profile]
        if config.proxy
          logger.debug "Using proxy #{config.proxy} from https_proxy environment variable."
        else
          logger.debug "Proxy environment variable https_proxy not set."
        end
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

        unless config.use_iam_profile
          required << :aws_access_key unless config.access_key
          required << :aws_secret_key unless config.secret_key
        end

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

      def ensure_valid_regions(args)
        regions = args[:regions]
        config = args[:config]
        regions.each do |region|
          ensure_valid_region :region => region, 
                              :config => config
        end
      end

      def ensure_valid_region(args)
        config = args[:config]
        region = args[:region]
        logger = config.logger
        valid_regions = ['us-east-1', 'us-west-1', 'us-west-2']

        unless valid_regions.include? region
          logger.error "'#{region}' is not a valid region."
          logger.error "Valid regions: #{valid_regions.join(', ')}"
          exit 1
        end
      end

      def ensure_metadata_in_upload_region(args)
        config  = args[:config]
        regions = args[:regions]
        logger  = config.logger

        unless regions.include? config.metadata_region
          logger.error "Upload Regions: '#{regions.join(', ')}'."
          logger.error "Metadata Region: '#{config.metadata_region}'."
          logger.error "Upload regions must include metadata region."
          exit 1
        end
      end

      def ensure_path_is_directory(args)
        config = args[:config]
        path = args[:path]
        logger = config.logger

        unless File.directory? path
          logger.error "#{path} is not a directory."
          exit 1
        end
      end

      def ensure_directory_is_writable(args)
        config = args[:config]
        path = args[:path]
        logger = config.logger

        unless File.writable? path
          logger.error "You don't have permissions to write to #{path}."
          exit 1
        end
      end

      def ensure_buckets_exist(args)
        config        = args[:config]
        bucket_prefix = args[:bucket_prefix]
        name          = args[:name]
        regions       = args[:regions]
        logger        = config.logger

        archive = Archive.new :name   => name,
                              :config => config

        unless archive.buckets_exist? :regions       => regions,
                                      :bucket_prefix => bucket_prefix
          logger.error "Required buckets for '#{bucket_prefix}' do not exist."
          exit 1
        end
      end

      def ensure_domain_exists(args)
        config = args[:config]
        name   = args[:name]
        logger = config.logger

        archive = Archive.new :name   => name,
                              :config => config

        unless archive.domain_exists?
          logger.error "'#{name}' metadata domain does not exist in '#{config.metadata_region}'."
          exit 1
        end
      end

      def ensure_archive_exists(args)
        archive = args[:archive]
        config  = args[:config]
        logger  = config.logger

        unless archive.exists?
          logger.error "Archive does not exist."
          exit 1
        end
      end

      def ensure_archive_domain_empty(args)
        config  = args[:config]
        archive = args[:archive]
        logger  = config.logger

        unless archive.count.zero?
          logger.error "Not empty."
          exit 1
        end
      end

      def ensure_catalog_domain_exists(args)
        config  = args[:config]
        catalog = args[:catalog]
        continue_on_error = args[:continue_on_error]
        logger  = config.logger
        region  = config.metadata_region

        unless catalog.catalog_domain_exists?
          logger.error "Catalog does not exist in #{region}."
          exit 1 unless continue_on_error
          return "foo" if continue_on_error
        end
      end

      def ensure_entry_exists_in_catalog(args)
        config  = args[:config]
        catalog = args[:catalog]
        entry   = args[:entry]
        logger  = config.logger
        region  = config.metadata_region

        unless catalog.entry_exists_in_catalog? entry
          logger.error "Entry for #{entry} does not exist in #{region} catalog."
          exit 1
        end
      end

      def ensure_buckets_available(args)
        config        = args[:config]
        regions       = args[:regions]
        bucket_prefix = args[:bucket_prefix]
        logger  = config.logger

        checker = Heirloom::Checker.new :config => config

        available = checker.bucket_name_available? :bucket_prefix => bucket_prefix,
                                                   :regions       => regions,
                                                   :config        => config
        if available
          true
        else
          logger.error "Bucket prefix #{bucket_prefix} not available across regions #{regions.join}."
          exit 1
        end
      end

      def ensure_entry_does_not_exist_in_catalog(args)
        config  = args[:config]
        catalog = args[:catalog]
        entry   = args[:entry]
        force   = args[:force]
        logger  = config.logger
        region  = config.metadata_region

        if catalog.entry_exists_in_catalog?(entry) && !force
          logger.error "Entry #{entry} exists in catalog. Use --force to overwrite."
          exit 1
        end
      end

      def ensure_valid_name(args)
        config = args[:config]
        name   = args[:name]
        logger = config.logger
        unless name =~ /^[0-9a-z\-\_]+$/
          logger.error "Invalid name '#{name}'. Can only contain lower case letters, numbers, dashes and underscores."
          exit 1
        end
      end

      def ensure_valid_bucket_prefix(args)
        config        = args[:config]
        bucket_prefix = args[:bucket_prefix]
        logger        = config.logger

        unless bucket_prefix =~ /^[0-9a-z\-]+$/
          logger.error "Invalid bucket prefix '#{bucket_prefix}'. Can only contain lower case letters, numbers and dashes."
          exit 1
        end
      end

      def latest_id(args)
        archive = Archive.new :name   => args[:name],
                              :config => args[:config]
        archive.list(1).first
      end

      def read_secret(args)
        opts   = args[:opts]
        config = args[:config]
        logger = config.logger

        return nil unless opts[:secret] || opts[:secret_file]

        return opts[:secret] if opts[:secret]

        unless File.exists? opts[:secret_file]
          logger.error "Unable to read #{opts[:secret_file]}."
          exit 1
        end

        (File.read opts[:secret_file]).chomp
      end
    end
  end
end
