module Heirloom
  module CLI
    class List

      include Heirloom::CLI::Shared

      def self.command_summary
        'List Heirloom IDs'
      end

      def initialize
        @opts = read_options
        @logger = HeirloomLogger.new :log_level => @opts[:level]
        @config = load_config :logger => @logger,
                              :opts   => @opts

        ensure_valid_options :provided => @opts,
                             :required => [:name],
                             :config   => @config
        ensure_valid_metadata_region @config
        ensure_domain_exists :name => @opts[:name], :config => @config

        @archive = Archive.new :name   => @opts[:name],
                               :config => @config
      end

      def list(count = @opts[:count])
        @logger.debug "#{@archive.count} IDs found."
        list = @archive.list count
        if @opts[:json]
          jj list
        else
          puts list.join "\n"
        end
      end

      private

      def read_options
        Trollop::options do
          version Heirloom::VERSION
          banner <<-EOS

#{List.command_summary}.

Usage:

heirloom list -n NAME

EOS
          opt :count, "Number of IDs to return.", :type    => :integer,
                                                  :default => 10
          opt :help, "Display Help"
          opt :level, "Log level [debug|info|warn|error].", :type    => :string,
                                                            :default => 'info'
          opt :metadata_region, "AWS region to store Heirloom metadata.", :type => :string
          opt :name, "Name of Heirloom.", :type => :string
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
