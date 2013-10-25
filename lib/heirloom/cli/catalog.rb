module Heirloom
  module CLI
    class Catalog

      include Heirloom::CLI::Shared

      def self.command_summary
        'Show catalog of Heirlooms'
      end

      def initialize
        @opts = read_options
        @logger = HeirloomLogger.new :log_level => @opts[:level]
        @config = load_config :logger => @logger,
                              :opts   => @opts

        ensure_valid_options :provided => @opts,
                             :required => [],
                             :config   => @config
      end


      def all
        results = detected_regions.select do |region|
          @config.metadata_region = region

          ensure_valid_region :region => region,
                              :config => @config

          next unless catalog_domain_exists?

          get_heirloom_info region
        end
        @logger.info "Heirloom #{@opts[:name]} not found in any region." unless results.any?
      end

      private

      def get_heirloom_info(region)
        f = formatter.format :region  => region,
                             :catalog => Hash[@catalog.all],
                             :name    => @opts[:name]

        f ? puts(f) : @logger.debug("Heirloom #{@opts[:name]} not found in catalog for #{region}.")
        f
      end

      def formatter
        @formatter ||= Heirloom::CLI::Formatter::Catalog.new
      end

      def catalog_domain_exists?
        @catalog = Heirloom::Catalog.new :config  => @config
        ensure_catalog_domain_exists :config  => @config,
                                     :catalog => @catalog,
                                     :continue_on_error => true
      end

      def default_regions
        %w(us-east-1 us-west-1 us-west-2)
      end

      def detected_regions
        return default_regions if @opts[:all_regions]
        Array(@opts[:metadata_region] || @config.metadata_region || default_regions)
      end

      def read_options
        Trollop::options do
          version Heirloom::VERSION
          banner <<-EOS

#{Catalog.command_summary}.

Usage:

heirloom catalog

          EOS
          opt :help, "Display Help"
          opt :level, "Log level [debug|info|warn|error].", :type    => :string,
                                                            :default => 'info'
          opt :name, "Name of Heirloom to show full details.", :type => :string
          opt :metadata_region, "AWS region to store Heirloom metadata.", :type => :string
          opt :all_regions, "Return catalog of all regions."
          opt :aws_access_key, "AWS Access Key ID", :type  => :string,
                                                    :short => :none
          opt :aws_secret_key, "AWS Secret Access Key", :type  => :string,
                                                        :short => :none
          opt :use_iam_profile, "Use IAM EC2 Profile", :short => :none
          opt :environment, "Environment (defined in ~/.heirloom.yml)", :type => :string
        end
      end

    end
  end
end
