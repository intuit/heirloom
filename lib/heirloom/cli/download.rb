module Heirloom
  module CLI
    class Download

      include Heirloom::CLI::Shared

      def self.command_summary
        'Download Heirloom'
      end

      def initialize
        @opts = read_options
        @logger = HeirloomLogger.new :log_level => @opts[:level]
        @config = load_config :logger => @logger,
                              :opts   => @opts

        ensure_valid_options :provided => @opts,
                             :required => [:name, :output],
                             :config   => @config

        @catalog = Heirloom::Catalog.new :name    => @opts[:name],
                                         :config  => @config

        # Determine if we can download directly from S3
        # Or if we need to query additional information from the catalog
        validate_or_bypass_catalog

        # Lookup id, region & bucket_prefix from simpledb unless specified
        # Can't use fetch as Trollop sets :id to nil
        @region        = @opts[:region] || @catalog.regions.first
        @bucket_prefix = @opts[:bucket_prefix] || @catalog.bucket_prefix
        id             = @opts[:id] || (latest_id :name   => @opts[:name],
                                                  :config => @config)

        @archive = Archive.new :name   => @opts[:name],
                               :config => @config,
                               :id     => id
      end

      def download
        ensure_path_is_directory     :path => @opts[:output], :config => @config
        ensure_directory_is_writable :path => @opts[:output], :config => @config
        secret = read_secret :opts   => @opts,
                             :config => @config
        archive = @archive.download :output        => @opts[:output],
                                    :extract       => @opts[:extract],
                                    :region        => @region,
                                    :bucket_prefix => @bucket_prefix,
                                    :secret        => secret
        exit 1 unless archive
      end

      private

      def validate_or_bypass_catalog
        missing_bypass_catalog_args = [:bucket_prefix, :id, :region].reject {|a| @opts[a]}

        if missing_bypass_catalog_args.none?
          @logger.info "Required arguments to download Heirloom without querying catalog provided. Downloading..."
        else
          @logger.info "Querying catalog for '#{@opts[:name]}' information."
          @logger.info "Add #{missing_bypass_catalog_args.join(', ')} to bypass querying catalog."

          # Only verify the domain exists in Heirloom
          # if we don't bypass the catalog
          ensure_catalog_domain_exists :config  => @config,
                                       :catalog => @catalog
          ensure_entry_exists_in_catalog :config  => @config,
                                         :catalog => @catalog,
                                         :entry   => @opts[:name]
        end
      end

      def read_options
        Trollop::options do
          version Heirloom::VERSION
          banner <<-EOS

#{Download.command_summary}.

Usage:

heirloom download -n NAME -o OUTPUT_DIRECTORY

If id (-i) is not specified, the latest id will be downloaded.

To download Heirloom without looking up details in SimpleDB, specify region (-r), ID (-i) and bucket_prefix (-b) options.

EOS
          opt :bucket_prefix, "Bucket prefix of the Heirloom to download.", :type => :string
          opt :extract, "Extract the Heirloom into the given output path.", :short => "-x"
          opt :help, "Display Help"
          opt :id, "ID of the Heirloom to download.", :type => :string
          opt :level, "Log level [debug|info|warn|error].", :type    => :string,
                                                            :default => 'info'
          opt :metadata_region, "AWS region to store Heirloom metadata.", :type => :string
          opt :name, "Name of Heirloom.", :type => :string
          opt :output, "Path to output downloaded Heirloom. Must be existing directory.", :type => :string
          opt :region, "Region to download Heirloom.", :type => :string
          opt :secret, "Secret for encrypted Heirloom.", :type => :string
          opt :secret_file, "Read secret from file.", :type  => :string,
                                                      :short => :none
          opt :aws_access_key, "AWS Access Key ID", :type => :string,
                                                    :short => :none
          opt :aws_secret_key, "AWS Secret Access Key", :type => :string,
                                                        :short => :none
          opt :use_iam_profile, "Use IAM EC2 Profile", :short => :none
          opt :environment, "Environment (defined in heirloom config file)", :type => :string
        end
      end
    end
  end
end
