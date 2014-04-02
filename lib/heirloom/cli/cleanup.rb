module Heirloom
  module CLI
    class Cleanup

      include Heirloom::CLI::Shared

      def self.command_summary
        "Delete old heirlooms not tagged with 'preserve': true"
      end

      def initialize
        @opts   = read_options
        @config = load_config :opts => @opts, :logger => Heirloom.log

        Heirloom.log.level = @opts[:log_level]

        ensure_valid_options :provided => @opts,
                             :required => [:name],
                             :config   => @config

        ensure_valid_metadata_region @config

        ensure_domain_exists :name   => @opts[:name],
                             :config => @config
      end

      def cleanup
        cat = Heirloom::Catalog.new :name => @opts[:name], :config => @config
        cat.cleanup :num_to_keep => @opts[:keep]
      rescue Heirloom::Exceptions::CleanupFailed => e
        Heirloom.log.error e.message
        exit 1
      end

      private

      def read_options
        Trollop::options do
          version Heirloom::VERSION
          banner <<-EOS

#{Cleanup.command_summary}.

Usage:

heirloom cleanup -n NAME -k 10

EOS
          opt :help, "Display Help"
          opt :log_level, "Log level [debug|info|warn|error].", :type    => :string,
                                                                :default => 'info'
          opt :metadata_region, "AWS region to store Heirloom metadata.", :type => :string
          opt :name, "Name of Heirloom.", :type => :string
          opt :keep, "Number of unpreserved heirlooms to keep.", :default => 100

          opt :aws_access_key, "AWS Access Key ID", :type  => :string, 
                                                    :short => :none
          opt :aws_secret_key, "AWS Secret Access Key", :type  => :string, 
                                                        :short => :none
          opt :environment, "Environment (defined in ~/.heirloom.yml)", :type => :string
        end
      end
    end
  end
end
