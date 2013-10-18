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
        detected_region.each { |region|
          @config.metadata_region = region

          ensure_valid_region :region => region,
                              :config => @config

          @catalog = Heirloom::Catalog.new :config  => @config

          next unless catalog_domain_exists?

          if @opts[:json]
            jj catalog_json_formatted
          else
            formatter = Heirloom::CLI::Formatter::Catalog.new
            puts formatter.format :region  => region,
                                  :catalog => catalog_cli_formatted,
                                  :name    => @opts[:name]
          end
        }
      end

      private

      def catalog_domain_exists?
        ensure_catalog_domain_exists :config  => @config,
                                     :catalog => @catalog,
                                     :continue_on_error => true
      end

      def detected_region
        r ||= @opts[:metadata_region]
        r ||= @config.metadata_region
        r &&= r.split
        r ||= ['us-west-1', 'us-east-1', 'us-west-2']
      end

      def catalog_json_formatted
        Hash[@catalog.all.sort.map { |k, v| [k.sub(/heirloom_/, ''), v] }]
      end

      def catalog_cli_formatted
        Hash[@catalog.all.sort.map { |k, v| [k.sub(/heirloom_/, '  '), v] }]
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
          opt :json, "Dump full catalog as raw JSON."
          opt :name, "Name of Heirloom to show full details.", :type => :string
          opt :metadata_region, "AWS region to store Heirloom metadata.", :type    => :string
          opt :aws_access_key, "AWS Access Key ID", :type => :string,
              :short => :none
          opt :aws_secret_key, "AWS Secret Access Key", :type => :string,
              :short => :none
          opt :use_iam_profile, "Use IAM EC2 Profile", :short => :none
          opt :environment, "Environment (defined in ~/.heirloom.yml)", :type => :string
        end
      end

    end
  end
end
