module Heirloom
  module CLI
    class Download

      include Heirloom::CLI::Shared

      def initialize
        @opts = read_options
        @logger = HeirloomLogger.new :log_level => @opts[:level]
        @config = load_config :logger => @logger,
                              :opts   => @opts

        ensure_valid_options :provided => @opts,
                             :required => [:base, :name, :id, :output],
                             :config   => @config

        @archive = Archive.new :name   => @opts[:name],
                               :id     => @opts[:id],
                               :config => @config
      end
      
      def download
        ensure_directory :path => @opts[:output], :config => @config
        ensure_valid_secret :secret => @opts[:secret], :config => @config
        archive = @archive.download :output      => @opts[:output],
                                    :region      => @opts[:region],
                                    :extract     => @opts[:extract],
                                    :base_prefix => @opts[:base],
                                    :secret      => @opts[:secret]
        exit 1 unless archive
      end

      private

      def read_options
        Trollop::options do
          version Heirloom::VERSION
          banner <<-EOS

Download an archive.

Usage:

heirloom download -n NAME -i ID -r REGION -o OUTPUT_DIRECTORY

EOS
          opt :base, "Base of the archive to download.", :type => :string
          opt :extract, "Extract the archive in the given output path.", :short => "-x"
          opt :help, "Display Help"
          opt :id, "ID of the archive to download.", :type => :string
          opt :level, "Log level [debug|info|warn|error].", :type    => :string,
                                                            :default => 'info'
          opt :name, "Name of archive.", :type => :string
          opt :output, "Path to output downloaded archive. Must be existing directory.", :type => :string
          opt :region, "Region to download archive.", :type    => :string,
                                                      :default => 'us-west-1'
          opt :secret, "Secret for ecrypted archive.", :type => :string
          opt :aws_access_key, "AWS Access Key ID", :type => :string, 
                                                    :short => :none
          opt :aws_secret_key, "AWS Secret Access Key", :type => :string, 
                                                        :short => :none
        end
      end
    end
  end
end
