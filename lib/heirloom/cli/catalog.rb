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
        regions = detected_regions
        @logger.info "Querying regions #{regions.join(', ')} for Heirloom catalogs."
        regions.each do |region|
          @config.metadata_region = region

          ensure_valid_metadata_region @config

          unless catalog_domain_exists?
            @logger.info "No heirloom catalog in '#{region}'."
            next
          end

          @catalog_list = Hash[@catalog.all]

          unless @opts[:name]
            heirloom_summary region
            @heirloom_found = true
            next
          end

          if heirloom_exists_in_catalog? @opts[:name]
            @logger.info "Heirloom \'#{@opts[:name]}\' found in catalog for #{region}."
            heirloom_details region, @opts[:name]
            @heirloom_found = true
          else
            @logger.info "Heirloom \'#{@opts[:name]}\' not found in catalog for #{region}."
          end
        end

        unless @heirloom_found
          if @opts[:name]
            @logger.info "Heirloom \'#{@opts[:name]}\' not found in any regions."
          else
            @logger.info "Heirloom catalog not found in any regions."
          end
        end
      end

      private

      def heirloom_summary(region)
        puts formatter.summary_format :region  => region
      end

      def heirloom_details(region,name)
        puts formatter.detailed_format :region  => region,
                                       :name    => name
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

      def formatter
        @formatter = Heirloom::CLI::Formatter::Catalog.new  :catalog => @catalog_list
      end

      def heirloom_exists_in_catalog?(name)
        @catalog_list.include? "heirloom_#{name}"
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
          opt :environment, "Environment (defined in heirloom config file)", :type => :string
        end
      end

    end
  end
end
