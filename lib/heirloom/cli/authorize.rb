require 'json'

module Heirloom
  module CLI
    class Authorize

      def initialize
        @opts = read_options
        @logger = HeirloomLogger.new :log_level => @opts[:level]

        exit 1 unless CLI::Shared.valid_options? :provided => @opts,
                                                 :required => [:accounts, 
                                                               :name, :id],
                                                 :logger   => @logger
        @archive = Archive.new :name   => @opts[:name],
                               :id     => @opts[:id],
                               :logger => @logger
      end

      def authorize
        @archive.authorize @opts[:accounts]
      end

      private

      def read_options
        Trollop::options do
          version Heirloom::VERSION
          banner <<-EOS

Build and upload a new archive.

Usage:

heirloom build -n NAME -i ID -a ACCOUNT_TO_AUTHORIZE -p

EOS
          opt :accounts, "AWS Account(s) email to authorize. Can be specified multiple times.", :type  => :string,
                                                                                                :multi => true
          opt :help, "Display Help"
          opt :id, "ID of the archive to display.", :type => :string
          opt :level, "Log level.", :type    => :string,
                                    :default => 'info'
          opt :name, "Name of archive.", :type => :string
        end
      end

    end
  end
end
