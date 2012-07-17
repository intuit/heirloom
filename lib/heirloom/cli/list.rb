module Heirloom
  module CLI
    class List

      def initialize
        @opts = read_options
        @logger = HeirloomLogger.new :log_level => @opts[:level]
        @heirloom = Heirloom.new :name   => @opts[:name],
                                 :logger => @logger
      end
      
      def list(count = @opts[:count])
        puts @heirloom.list(count)
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
          opt :level, "Log level.", :type    => :string,
                                    :default => 'info'
          opt :name, "Name of Heirloom.", :type => :string
          opt :count, "Number of versions to return.", :type    => :integer,
                                                       :default => 10
        end
      end

    end
  end
end
