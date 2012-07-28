module Heirloom
  module CLI
    class Destroy

      def initialize
        @opts = read_options
        @logger = HeirloomLogger.new :log_level => @opts[:level]
        exit 1 unless CLI::Shared.valid_options? :provided => @opts,
                                                 :required => [:name, :id],
                                                 :logger   => @logger
        @name = @opts[:name]
        @id = @opts[:id]
        @archive = Archive.new :name   => @name,
                               :id     => @id,
                               :logger => @logger
      end
      
      def destroy
        @archive.destroy
      end

      private

      def read_options
        Trollop::options do
          version Heirloom::VERSION
          banner <<-EOS

Destroy an archive.

Usage:

heirloom destroy -n NAME -i ID [-l LOG_LEVEL]

EOS
          opt :help, "Display Help"
          opt :id, "ID of the archive to display.", :type => :string
          opt :level, "Log level.", :type    => :string,
                                    :default => 'info'
          opt :name, "Name of archive.", :type => :string
        end
      end
    end
  end
end
