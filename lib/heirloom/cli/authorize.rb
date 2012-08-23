module Heirloom
  module CLI
    class Authorize

      include Heirloom::CLI::Shared

      def initialize
        @opts = read_options
        @logger = HeirloomLogger.new :log_level => @opts[:level]
        @config = load_config :logger => @logger,
                              :opts   => @opts

        ensure_valid_options :provided => @opts,
                             :required => [:accounts, :name, :id],
                             :config   => @config
        ensure_valid_region :region => @opts[:metadata_region],
                            :config => @config
        ensure_domain_exists :name => @opts[:name], 
                             :config => @config
        @archive = Archive.new :name   => @opts[:name],
                               :id     => @opts[:id],
                               :config => @config
        ensure_archive_exists :archive => @archive,
                              :config => @config
      end

      def authorize
        unless @archive.authorize @opts[:accounts]
          exit 1
        end
      end

      private

      def read_options
        Trollop::options do
          version Heirloom::VERSION
          banner <<-EOS

Authorize access from another AWS account to an archive.

Usage:

heirloom authorize -n NAME -i ID -a AWS_ACCOUNT1 -a AWS_ACCOUNT2

Note: This will replace all current authorizations with those specified and make the archive private.

EOS
          opt :accounts, "AWS Account(s) email to authorize. Can be specified multiple times.", :type  => :string,
                                                                                                :multi => true
          opt :help, "Display Help"
          opt :id, "ID of the archive to authorize.", :type => :string
          opt :level, "Log level [debug|info|warn|error].", :type    => :string,
                                                            :default => 'info'
          opt :metadata_region, "AWS region to store Heirloom metadata.", :type    => :string,   
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
