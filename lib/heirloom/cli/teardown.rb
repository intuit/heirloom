module Heirloom
  module CLI
    class Teardown

      include Heirloom::CLI::Shared

      def initialize
        @opts = read_options
        @logger = HeirloomLogger.new :log_level => @opts[:level]
        @config = load_config :logger => @logger,
                              :opts   => @opts

        ensure_valid_options :provided => @opts, 
                             :required => [:name],
                             :config   => @config

        @catalog = Catalog.new :name    => @opts[:name],
                               :config  => @config
        @archive = Archive.new :name   => @opts[:name],
                               :config => @config

        @regions = @catalog.regions
        @base    = @catalog.base
      end

      def teardown
        ensure_domain_exists :name   => @opts[:name],
                             :config => @config

        ensure_archive_domain_empty :archive => @archive,
                                    :config  => @config

        unless @opts[:keep_buckets]
          @archive.delete_buckets :regions       => @regions,
                                  :bucket_prefix => @base
        end

        @archive.delete_domain
        @catalog.delete_from_catalog :name => @opts[:name]
      end

      private

      def read_options
        Trollop::options do
          version Heirloom::VERSION
          banner <<-EOS

Teardown S3 buckets and SimpleDB domain for a given Heirloom.

Usage:

heirloom teardown -n NAME

EOS
          opt :help, "Display Help"
          opt :level, "Log level [debug|info|warn|error].", :type    => :string,
                                                            :default => 'info'
          opt :metadata_region, "AWS region to store Heirloom metadata.", :type    => :string,
                                                                          :default => 'us-west-1'
          opt :name, "Name of archive.", :type => :string
          opt :keep_buckets, "Do not delete S3 buckets."
          opt :aws_access_key, "AWS Access Key ID", :type => :string, 
                                                    :short => :none
          opt :aws_secret_key, "AWS Secret Access Key", :type => :string, 
                                                        :short => :none
        end
      end

    end
  end
end
