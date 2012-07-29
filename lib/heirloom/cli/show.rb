module Heirloom
  module CLI
    class Show

      def initialize
        @opts = read_options
        @logger = HeirloomLogger.new :log_level => @opts[:level]
        exit 1 unless CLI::Shared.valid_options? :provided => @opts,
                                                 :required => [:name],
                                                 :logger   => @logger
        id = @opts[:id] ? @opts[:id] : latest_id
        @archive = Archive.new :name   => @opts[:name],
                               :logger => @logger,
                               :id     => id
      end
      
      def show
        jj @archive.show
      end

      private

      def latest_id
        @archive = Archive.new :name => @opts[:name]
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
          opt :level, "Log level.", :type    => :string,
                                    :default => 'info'
          opt :name, "Name of archive.", :type => :string
          opt :id, "ID of the archive to display.", :type => :string
        end
      end

    end
  end
end
