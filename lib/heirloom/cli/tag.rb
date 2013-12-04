module Heirloom
  module CLI
    class Tag

      include Heirloom::CLI::Shared

      def self.command_summary
        'Tag an Heirloom with an attribute and value'
      end

      def initialize
        @opts = read_options
        @logger = HeirloomLogger.new :log_level => @opts[:level]
        @config = load_config :logger => @logger,
                              :opts   => @opts

        ensure_valid_options :provided => @opts,
                             :required => [:name, :id, :attribute, :value],
                             :config   => @config
        ensure_valid_region :region => @opts[:metadata_region],
                            :config => @config
        ensure_domain_exists :name => @opts[:name], :config => @config

        @archive = Archive.new :name   => @opts[:name],
                               :id     => @opts[:id],
                               :config => @config
        ensure_archive_exists :archive => @archive,
                              :config => @config
      end
      
      def tag
        unless @archive.exists?
          @logger.error "Archive does not exist"
          exit 1
        end
        @archive.update :attribute  => @opts[:attribute],
                        :value      => @opts[:value]
      end

      private

      def read_options
        Trollop::options do
          version Heirloom::VERSION
          banner <<-EOS

#{Tag.command_summary}.

Usage:

heirloom tag -n NAME -i ID -a ATTRIBUTE -u VALUE

EOS
          opt :attribute, "Attribute to update.", :type => :string
          opt :help, "Display Help"
          opt :id, "ID of the Heirloom to tag.", :type => :string
          opt :level, "Log level [debug|info|warn|error].", :type    => :string,
                                                            :default => 'info'
          opt :metadata_region, "AWS region to store Heirloom metadata.", :type    => :string
          opt :name, "Name of Heirloom.", :type => :string
          opt :value, "Value of attribute.", :type  => :string,
                                             :short => 'u'
          opt :aws_access_key, "AWS Access Key ID", :type  => :string, 
                                                    :short => :none
          opt :aws_secret_key, "AWS Secret Access Key", :type  => :string, 
                                                        :short => :none
          opt :use_iam_profile, "Use IAM EC2 Profile", :short => :none
          opt :environment, "Environment (defined in ~/.heirloom.yml)", :type => :string
        end
      end
    end
  end
end
