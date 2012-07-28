module Heirloom
  module CLI
    class Show

      def initialize
        @opts = read_options
        CLI::Shared.valid_options? :provided => @opts,
                                   :required => [:name]
        id = @opts[:id] ? @opts[:id] : latest_id
        @logger = HeirloomLogger.new :log_level => @opts[:level]
        @archive = Archive.new :name   => @opts[:name],
                               :id     => id,
                               :logger => @logger
      end
      
      def show
        puts @archive.show.to_yaml
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
