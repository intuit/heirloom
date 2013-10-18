module Heirloom
  module CLI
    class CatalogGlobal

      include Heirloom::CLI::Shared

      def self.command_summary
        'Show catalog of Heirlooms'
      end

      def initialize
        @opts = read_options
        @logger = HeirloomLogger.new :log_level => @opts[:level]
        @config = load_config :logger => @logger,
                              :opts   => @opts


        #ensure_valid_options :provided => @opts,
        #                     :required => [],
        #                     :config   => @config
        #ensure_valid_region :region => @opts[:metadata_region],
        #                    :config => @config
        #@catalog = Heirloom::Catalog.new :config  => @config
        #ensure_catalog_domain_exists :config  => @config,
        #                             :catalog => @catalog
      end


      def all
        regions = ['us-west-1', 'us-east-1', 'us-west-2']
        #regions = ['us-east-1']
        regions.each { |region| @config.metadata_region = region
          ensure_valid_region :region => region,
                              :config => @config

          @catalog = Heirloom::Catalog.new :config  => @config
          f = ensure_catalog_domain_exists :config  => @config,
                                       :catalog => @catalog,
                                       :continue_on_error => true
          if f == "foo"
            next
          end
          formatter = Heirloom::CLI::Formatter::Catalog.new
          formatted = formatter.format :catalog => catalog_with_heirloom_prefix_removed,
                                     :name    => @opts[:name]
          puts " " + region
          puts formatted
        }
      end

      private

      def catalog_with_heirloom_prefix_removed
        Hash[@catalog.all.sort.map { |k, v| [k.sub(/heirloom_/, ''), v] }]
      end

      def read_options
        Trollop::options do
          version Heirloom::VERSION
          banner <<-EOS

#{Catalog.command_summary}.

Usage:

heirloom catalog_global

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
