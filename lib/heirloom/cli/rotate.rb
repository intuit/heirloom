module Heirloom
  module CLI
    class Rotate

      include Heirloom::CLI::Shared

      def self.command_summary
        'Rotate keys for an Heirloom'
      end

      def initialize
        @opts = read_options
        @logger = HeirloomLogger.new :log_level => @opts[:level]
        @config = load_config :logger => @logger,
                              :opts   => @opts

        ensure_valid_options :provided => @opts,
                             :required => [:name, :id, :old_secret, :new_secret],
                             :config   => @config

        @catalog = Heirloom::Catalog.new :name   => @opts[:name],
                                         :config => @config

        @archive = Archive.new :name   => @opts[:name],
                               :config => @config,
                               :id     => @opts[:id]

        unless @opts[:bucket_prefix]
          ensure_archive_exists :archive => @archive,
                                :config  => @config
        end

        # Lookup upload regions, metadata region, and bucket_prefix from simpledb unless specified
        @opts[:regions]       ||= @catalog.regions
        @opts[:region]        ||= @catalog.regions.first
        @opts[:bucket_prefix] ||= @catalog.bucket_prefix
      end

      def rotate
        @archive.rotate @opts
      rescue Heirloom::Exceptions::RotateFailed => e
        @config.logger.error e.message
        exit 1
      end

      private

      def read_options
        Trollop::options do
          version Heirloom::VERSION
          banner <<-EOS

#{Rotate.command_summary}.  

Will download the heirloom to temp directory, decrypt, encrypt, and upload, replacing original.

Usage:

heirloom rotate -n NAME -i ID --new-secret MY_NEW_SECRET --old-secret MY_OLD_SECRET

To rotate Heirloom without looking up details in SimpleDB, specify region (-r) and bucket_prefix (-b) options.

EOS
          opt :bucket_prefix, "Bucket prefix of the Heirloom to download.", :type => :string
          opt :help, "Display Help"
          opt :id, "ID of the Heirloom to rotate.", :type => :string
          opt :level, "Log level [debug|info|warn|error].", :type    => :string,
                                                            :default => 'info'
          opt :metadata_region, "AWS region to store Heirloom metadata.", :type    => :string
          opt :name, "Name of Heirloom.", :type => :string
          opt :region, "Region to download Heirloom.", :type    => :string,
                                                       :default => 'us-west-1'
          opt :new_secret, "New Secret for encrypted Heirloom.", :type => :string,
                                                                 :short => :none
          opt :old_secret, "Old secret for encrypted Heirloom.", :type => :string,
                                                                 :short => :none
          opt :aws_access_key, "AWS Access Key ID", :type => :string, 
                                                    :short => :none
          opt :aws_secret_key, "AWS Secret Access Key", :type => :string, 
                                                        :short => :none
          opt :environment, "Environment (defined in heirloom config)", :type => :string
        end
      end
    end
  end
end
