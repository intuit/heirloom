module Heirloom
  module CLI
    class Download

      def initialize
        @opts = read_options
        @logger = HeirloomLogger.new :log_level => @opts[:level]
        @archive = Archive.new :name   => @opts[:name],
                               :id     => @opts[:id],
                               :logger => @logger
      end
      
      def download
        @archive.download :output => @opts[:output],
                          :region => @opts[:region]
      end

      private

      def read_options
        Trollop::options do
          version Heirloom::VERSION
          banner <<-EOS

Download an archive.

Usage:

heirloom download -n NAME -i ID -r REGION -o OUTPUT_FILE

EOS
          opt :help, "Display Help"
          opt :id, "ID of the archive to display.", :type => :string
          opt :level, "Log level.", :type    => :string,
                                    :default => 'info'
          opt :name, "Name of archive.", :type => :string
          opt :output, "Location to download archive.", :type => :string
          opt :region, "Region to download archive.", :type    => :string,
                                                       :default => 'us-west-1'
        end
      end
    end
  end
end
