module Heirloom
  module CLI
    class Teardown

      include Heirloom::CLI::Shared

      def self.command_summary
        'Teardown S3 buckets and SimpleDB domain for Heirloom name'
      end

      def initialize
        @opts = read_options
        @logger = HeirloomLogger.new :log_level => @opts[:level]
        @config = load_config :logger => @logger,
                              :opts   => @opts

        ensure_valid_metadata_region @config
        ensure_valid_options :provided => @opts,
                             :required => [:name],
                             :config   => @config

        @catalog = Heirloom::Catalog.new :name    => @opts[:name],
                                         :config  => @config
        @archive = Archive.new :name   => @opts[:name],
                               :config => @config

        ensure_catalog_domain_exists :config  => @config,
                                     :catalog => @catalog
        ensure_entry_exists_in_catalog :config  => @config,
                                       :catalog => @catalog,
                                       :entry   => @opts[:name]
      end

      def teardown
        ensure_domain_exists :name => @opts[:name], :config => @config

        if @opts[:force]
          Heirloom.log.info "Removing any existing archives..."
          @catalog.cleanup :num_to_keep => 0, :remove_preserved => true
        else
          ensure_archive_domain_empty(
            :archive => @archive,
            :config  => @config
          )
        end

        unless @opts[:keep_buckets]
          @archive.delete_buckets(
            :regions       => @catalog.regions,
            :bucket_prefix => @catalog.bucket_prefix
          )
        end

        @archive.delete_domain
        @catalog.delete_from_catalog
      end

      private

      def read_options
        Trollop::options do
          version Heirloom::VERSION
          banner <<-EOS

#{Teardown.command_summary}.

Usage:

heirloom teardown -n NAME

Note: All Heirlooms must be destroyed.

EOS
          opt :help, "Display Help"
          opt :level, "Log level [debug|info|warn|error].", :type    => :string,
                                                            :default => 'info'
          opt :metadata_region, "AWS region to store Heirloom metadata.", :type    => :string
          opt :name, "Name of Heirloom.", :type => :string
          opt :force, "Forces recursive deletion of existing archives."
          opt :keep_buckets, "Do not delete S3 buckets."
          opt :aws_access_key, "AWS Access Key ID", :type => :string, 
                                                    :short => :none
          opt :aws_secret_key, "AWS Secret Access Key", :type => :string, 
                                                        :short => :none
          opt :use_iam_profile, "Use IAM EC2 Profile", :short => :none
          opt :environment, "Environment (defined in ~/.heirloom.yml)", :type => :string
        end
      end

    end
  end
end
