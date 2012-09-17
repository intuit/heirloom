module Heirloom
  module CLI
    class Catalog

      include Heirloom::CLI::Shared

      def initialize
        @opts = read_options
        @logger = HeirloomLogger.new :log_level => @opts[:level]
        @config = load_config :logger => @logger,
                              :opts   => @opts

        ensure_valid_options :provided => @opts,
                             :required => [],
                             :config   => @config
        ensure_valid_region :region => @opts[:metadata_region],
                            :config => @config
        @catalog = Heirloom::Catalog.new :config  => @config
        ensure_catalog_domain_exists :config  => @config,
                                     :catalog => @catalog
      end
      
      def all
        if @opts[:json]
          jj catalog_with_heirloom_prefix_removed
        else
          formatter = Heirloom::CLI::Formatter::Catalog.new 
          puts formatter.format :catalog => catalog_with_heirloom_prefix_removed,
                                :name    => @opts[:name]
        end
      end

      private

      def catalog_with_heirloom_prefix_removed
        Hash[@catalog.all.sort.map { |k, v| [k.sub(/heirloom_/, ''), v] }]
      end

      def read_options
        Trollop::options do
          version Heirloom::VERSION
          banner <<-EOS

Show catalog of Heirlooms.

Usage:

heirloom catalog

EOS
          opt :help, "Display Help"
          opt :level, "Log level [debug|info|warn|error].", :type    => :string,
                                                            :default => 'info'
          opt :json, "Dump full catalog as raw JSON."
          opt :name, "Name of Heirloom to show full details.", :type => :string
          opt :metadata_region, "AWS region to store Heirloom metadata.", :type    => :string,   
                                                                          :default => 'us-west-1'
          opt :aws_access_key, "AWS Access Key ID", :type => :string, 
                                                    :short => :none
          opt :aws_secret_key, "AWS Secret Access Key", :type => :string, 
                                                        :short => :none
        end
      end

    end
  end
end
