require 'json'

module Heirloom
  module CLI
    class Authorize

      def initialize
        @opts = read_options
        @logger = HeirloomLogger.new :log_level => @opts[:level]
        @config = CLI::Shared.load_config :logger => @logger,
                                          :opts   => @opts
        exit 1 unless CLI::Shared.valid_options? :provided => @opts,
                                                 :required => [:accounts, 
                                                               :name, :id],
                                                 :logger   => @logger
        @archive = Archive.new :name   => @opts[:name],
                               :id     => @opts[:id],
                               :config => @config
      end

      def authorize
        @archive.authorize @opts[:accounts]
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
          opt :id, "id of the archive to authorize.", :type => :string
          opt :key, "AWS Access Key", :type => :string
          opt :level, "Log level [debug|info|warn|error].", :type    => :string,
                                                            :default => 'info'
          opt :secret, "AWS Secret Access Key", :type => :string
          opt :name, "Name of archive.", :type => :string
        end
      end

    end
  end
end
