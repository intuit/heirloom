module Heirloom
  module CLI
    class Show

      include Heirloom::CLI::Shared

      def initialize
        @opts = read_options
        @logger = HeirloomLogger.new :log_level => @opts[:level]
        @config = load_config :logger => @logger,
                              :opts   => @opts

        ensure_valid_options :provided => @opts,
                             :required => [:name],
                             :config   => @config
        ensure_valid_region :region => @opts[:metadata_region],
                            :config => @config
        ensure_domain_exists :name => @opts[:name], :config => @config

        id = @opts[:id] ? @opts[:id] : latest_id
        @archive = Archive.new :name   => @opts[:name],
                               :config => @config,
                               :id     => id
      end
      
      def show
        jj @archive.show
      end

      private

      def latest_id
        @archive = Archive.new :name   => @opts[:name],
                               :config => @config
        @archive.list(1).first
      end

      def read_options
        Trollop::options do
          version Heirloom::VERSION
          banner <<-EOS

Show archive.

Usage:

heirloom show -n NAME -i ID

If -i is ommited, latest ID is displayed.

EOS
          opt :help, "Display Help"
          opt :id, "ID of the archive to display.", :type => :string
          opt :level, "Log level [debug|info|warn|error].", :type    => :string,
                                                            :default => 'info'
          opt :metadata_region, "Location of Heirloom metadata.", :type    => :string,   
                                                                  :default => 'us-west-1'
          opt :name, "Name of archive.", :type => :string
          opt :aws_access_key, "AWS Access Key ID", :type => :string, 
                                                    :short => :none
          opt :aws_secret_key, "AWS Secret Access Key", :type => :string, 
                                                        :short => :none
        end
      end

    end
  end
end
