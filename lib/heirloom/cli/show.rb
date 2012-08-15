module Heirloom
  module CLI
    class Show

      include Heirloom::CLI::Shared

      def initialize
        @opts = read_options
        @logger = HeirloomLogger.new :log_level => @opts[:level]
        @config = load_config :logger => @logger,
                              :opts   => @opts

        exit 1 unless valid_options? :provided => @opts,
                                     :required => [:name],
                                     :logger   => @logger

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

Show details about a version of an archive.

Usage:

heirloom show -n NAME -i ID

If -i is ommited, latest version is displayed.

EOS
          opt :help, "Display Help"
          opt :key, "AWS Access Key ID", :type => :string
          opt :level, "Log level [debug|info|warn|error].", :type    => :string,
                                                            :default => 'info'
          opt :name, "Name of archive.", :type => :string
          opt :id, "ID of the archive to display.", :type => :string
          opt :secret, "AWS Secret Access Key", :type => :string
        end
      end

    end
  end
end
