module Heirloom
  module CLI
    class Setup

      include Heirloom::CLI::Shared

      def self.command_summary
        'Setup S3 and SimpleDB in the given regions'
      end

      def initialize
        @opts = read_options
        @logger = HeirloomLogger.new :log_level => @opts[:level]
        @config = load_config :logger => @logger,
                              :opts   => @opts

        ensure_valid_options :provided => @opts,
                             :required => [:bucket_prefix,
                                           :region, :name],
                             :config   => @config

        @catalog = Heirloom::Catalog.new :name    => @opts[:name],
                                         :config  => @config
        @archive = Archive.new :name   => @opts[:name],
                               :config => @config
      end

      def setup
        ensure_valid_metadata_region @config

        ensure_valid_regions :regions => @opts[:region],
                             :config  => @config

        ensure_metadata_in_upload_region :config  => @config,
                                         :regions => @opts[:region]

        ensure_valid_name :config => @config,
                          :name   => @opts[:name]

        ensure_valid_bucket_prefix :config        => @config,
                                   :bucket_prefix => @opts[:bucket_prefix]

        @catalog.create_catalog_domain

        ensure_entry_does_not_exist_in_catalog :config  => @config,
                                               :catalog => @catalog,
                                               :entry   => @opts[:name],
                                               :force   => @opts[:force]

        ensure_buckets_available :config        => @config,
                                 :bucket_prefix => @opts[:bucket_prefix],
                                 :regions       => @opts[:region]

        @catalog.add_to_catalog :regions       => @opts[:region],
                                :bucket_prefix => @opts[:bucket_prefix]

        @archive.setup :regions       => @opts[:region],
                       :bucket_prefix => @opts[:bucket_prefix]
      end

      private

      def read_options
        Trollop::options do
          version Heirloom::VERSION
          banner <<-EOS

#{Setup.command_summary}.

Usage:

heirloom setup -b BUCKET_PREFIX -n NAME -m REGION1 -r REGION1 -r REGION2

EOS
          opt :bucket_prefix, "The bucket prefix will be combined with specified \
regions to create the required buckets. For example: '-b test -r us-west-1 -r \
us-east-1' will create bucket test-us-west-1 in us-west-1 and test-us-east-1 in us-east-1.", :type => :string
          opt :force, "Overwrite existing catalog entries."
          opt :help, "Display Help"
          opt :level, "Log level [debug|info|warn|error].", :type    => :string,
                                                            :default => 'info'
          opt :metadata_region, "AWS region to store Heirloom metadata.", :type    => :string
          opt :name, "Name of Heirloom.", :type => :string
          opt :region, "AWS Region(s) to upload Heirloom. \
Can be specified multiple times.", :type  => :string, 
                                   :multi => true,
                                   :default => 'us-west-1'
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
