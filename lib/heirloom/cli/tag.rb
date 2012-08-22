module Heirloom
  module CLI
    class Tag

      include Heirloom::CLI::Shared

      def initialize
        @opts = read_options
        @logger = HeirloomLogger.new :log_level => @opts[:level]
        @config = load_config :logger => @logger,
                              :opts   => @opts

        ensure_valid_options :provided => @opts,
                             :required => [:name, :id, :attribute, :value],
                             :config   => @config

        ensure_domain_exists :name => @opts[:name], :config => @config

        @archive = Archive.new :name   => @opts[:name],
                               :id     => @opts[:id],
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

Tag an archive with an attribute and value.

Usage:

heirloom tag -n NAME -i ID -a ATTRIBUTE -u VALUE

EOS
          opt :attribute, "Attribute to update.", :type => :string
          opt :help, "Display Help"
          opt :id, "ID of the archive to display.", :type => :string
          opt :level, "Log level [debug|info|warn|error].", :type    => :string,
                                                            :default => 'info'
          opt :metadata, "Location of Heirloom metadata.", :type    => :string,   
                                                           :default => 'us-west-1'
          opt :name, "Name of archive.", :type => :string
          opt :value, "Value of attribute.", :type  => :string,
                                             :short => 'u'
          opt :aws_access_key, "AWS Access Key ID", :type  => :string, 
                                                    :short => :none
          opt :aws_secret_key, "AWS Secret Access Key", :type  => :string, 
                                                        :short => :none
        end
      end
    end
  end
end
