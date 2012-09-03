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
      end
      
      def list
        if @opts[:details]
          jj catalog_with_heirloom_prefix_removed
        else
          jj catalog_with_heirloom_prefix_removed.keys
        end
      end

      private

      def catalog_with_heirloom_prefix_removed
        Hash[@catalog.all.map { |k, v| [k.sub(/heirloom_/, ''), v] }]
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
          opt :details, "Include details."
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
