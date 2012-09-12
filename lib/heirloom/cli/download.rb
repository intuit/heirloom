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
                             :required => [:name, :output],
                             :config   => @config

        @catalog = Heirloom::Catalog.new :name    => @opts[:name],
                                         :config  => @config

        # Can't use fetch as Trollop sets :id to nil
        id = @opts[:id] ||( latest_id :name   => @opts[:name],                                              
                                      :config => @config)

        @archive = Archive.new :name   => @opts[:name],
                               :id     => id,
                               :config => @config

        # Lookup region & base from simpledb unless specified
        # To Do, valid validation message that simpledb exists
        @region = @opts[:region] || @catalog.regions.first
        @base   = @opts[:base]   || @catalog.base
      end
      
      def download
        ensure_directory :path => @opts[:output], :config => @config
        secret = read_secret :opts   => @opts,
                             :config => @config
        ensure_valid_secret :secret => secret, 
                            :config => @config
        archive = @archive.download :output      => @opts[:output],
                                    :extract     => @opts[:extract],
                                    :region      => @region,
                                    :base_prefix => @base,
                                    :secret      => secret
        exit 1 unless archive
      end

      private

      def read_options
        Trollop::options do
          version Heirloom::VERSION
          banner <<-EOS

Download Heirloom.

Usage:

heirloom download -n NAME -o OUTPUT_DIRECTORY

If id (-i) is not specified, the latest id will be downloaded.

To download Heirloom without looking up details in SimpleDB, specify region (-r), ID (-i) and base (-b) options.

EOS
          opt :base, "Base of the Heirloom to download.", :type => :string
          opt :extract, "Extract the Heirloom into the given output path.", :short => "-x"
          opt :help, "Display Help"
          opt :id, "ID of the Heirloom to download.", :type => :string
          opt :level, "Log level [debug|info|warn|error].", :type    => :string,
                                                            :default => 'info'
          opt :metadata_region, "AWS region to store Heirloom metadata.", :type    => :string,
                                                                          :default => 'us-west-1'
          opt :name, "Name of Heirloom.", :type => :string
          opt :output, "Path to output downloaded Heirloom. Must be existing directory.", :type => :string
          opt :region, "Region to download Heirloom.", :type    => :string,
                                                      :default => 'us-west-1'
          opt :secret, "Secret for ecrypted Heirloom.", :type => :string
          opt :secret_file, "Read secret from file.", :type  => :string,
                                                      :short => :none
          opt :aws_access_key, "AWS Access Key ID", :type => :string, 
                                                    :short => :none
          opt :aws_secret_key, "AWS Secret Access Key", :type => :string, 
                                                        :short => :none
        end
      end
    end
  end
end
