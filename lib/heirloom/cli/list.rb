module Heirloom
  module CLI
    class List

      include Heirloom::CLI::Shared

      def initialize
        @opts = read_options
        @logger = HeirloomLogger.new :log_level => @opts[:level]
        @config = load_config :logger => @logger,
                              :opts   => @opts

        ensure_valid_options :provided => @opts,
                             :required => [:name],
                             :config   => @config
        ensure_valid_region :region => @opts[:metadata_region],
                            :config => @config
        ensure_domain_exists :name => @opts[:name], :config => @config

        @archive = Archive.new :name   => @opts[:name],
                               :config => @config
      end
      
      def list(count = @opts[:count])
        @logger.debug "#{@archive.count} archives found."
        jj @archive.list(count)
      end

      private

      def read_options
        Trollop::options do
          version Heirloom::VERSION
          banner <<-EOS

List available IDs of archive.

Usage:

heirloom list -n NAME

EOS
          opt :count, "Number of IDs to return.", :type    => :integer,
                                                  :default => 10
          opt :help, "Display Help"
          opt :level, "Log level [debug|info|warn|error].", :type    => :string,
                                                            :default => 'info'
          opt :metadata_region, "Location of Heirloom metadata.", :type    => :string,   
                                                                  :default => 'us-west-1'
          opt :name, "Name of archive.", :type => :string
          opt :aws_access_key, "AWS Access Key ID", :type => :string, 
                                                    :short => :none
          opt :aws_secret_key, "AWS Secret Access Key", :type => :string, 
                                                        :short => :none
        end
      end

    end
  end
end
