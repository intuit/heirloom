module Heirloom
  module CLI
    module Shared

      def load_config(args)
        opts = args[:opts]
        logger = args[:logger]
        config = Config.new :logger => logger
        config.access_key = opts[:aws_access_key] if opts[:aws_access_key]
        config.secret_key = opts[:aws_secret_key] if opts[:aws_secret_key]
        config.metadata_region = opts[:metadata_region] if opts[:metadata_region]
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

      def ensure_directory(args)
        config = args[:config]
        path = args[:path]
        logger = config.logger

        unless File.directory? path
          logger.error "#{path} is not a directory."
          exit 1
        end
      end

      def ensure_buckets_exist(args)
        config  = args[:config]
        base    = args[:base]
        name    = args[:name]
        regions = args[:regions]
        logger  = config.logger

        archive = Archive.new :name   => name,
                              :config => config

        unless archive.buckets_exist? :regions       => regions,
                                      :bucket_prefix => base
          logger.error "Required buckets for '#{base}' do not exist."
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
          logger.error "'#{name}' does not exist in '#{config.metadata_region}' catalog."
          exit 1
        end
      end

      def ensure_archive_exists(args)
        config  = args[:config]
        archive = args[:archive]
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
        logger  = config.logger
        region  = config.metadata_region

        unless catalog.catalog_domain_exists?
          logger.error "Catalog does not exist in #{region}."
          exit 1
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

      def latest_id(args)
        archive = Archive.new :name   => args[:name],
                              :config => args[:config]
        archive.list(1).first
      end
    end
  end
end
