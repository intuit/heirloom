module Heirloom
  module CLI
    class Show

      def initialize
        @opts = read_options
        id = @opts[:id] ? @opts[:id] : latest_id
        @logger = HeirloomLogger.new :log_level => @opts[:level]
        @heirloom = Heirloom.new :name   => @opts[:name],
                                 :id     => id,
                                 :logger => @logger
      end
      
      def show
        puts @heirloom.show.to_yaml
      end

      private

      def latest_id
        @heirloom = Heirloom.new :name => @opts[:name]
        @heirloom.list(1).first
      end

      def read_options
        Trollop::options do
          version Heirloom::VERSION
          banner <<-EOS

Show details about a version of an heirloom.

Usage:

heirloom show -n NAME -i ID

If -i is ommited, latest version is displayed.

EOS
          opt :help, "Display Help"
          opt :level, "Log level.", :type    => :string,
                                    :default => 'info'
          opt :name, "Name of Heirloom.", :type => :string
          opt :id, "ID of the Heirloom to display.", :type => :string
        end
      end

    end
  end
end
