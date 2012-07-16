module Heirloom
  module CLI
    class List

      def initialize
        @opts = read_options
        @logger = HeirloomLogger.new :log_level => @opts[:level]
        @artifact = Heirloom.new :name   => @opts[:name],
                                 :logger => @logger
      end
      
      def list(limit=@opts[:limit])
        puts @artifact.list(limit)
      end

      private

      def read_options
        Trollop::options do
          version Heirloom::VERSION
          banner <<-EOS

List versions of heirloom.

Usage:

heirloom list -n NAME

EOS
          opt :help, "Display Help"
          opt :name, "Name of artifact.", :type => :string
          opt :limit, "Number of artifacts to return.", :type    => :integer,
                                                        :default => 10
        end
      end

    end
  end
end
