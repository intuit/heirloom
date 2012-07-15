module Heirloom
  module CLI
    class Download

      def initialize
        @opts = read_options
        @heirloom = Heirloom.new :name => @opts[:name],
                                 :id   => @opts[:id]
      end
      
      def download
        @heirloom.download :output => @opts[:output],
                           :region => @opts[:region]
      end

      private

      def read_options
        Trollop::options do
          version Heirloom::VERSION
          banner <<-EOS

Update an heirloom attribute.

Usage:

heirloom update -n NAME -i ID -a ATTRIBUTE_TO_UPDATE -v NEW_VALUE

EOS
          opt :help, "Display Help"
          opt :id, "ID of the heirloom to display.", :type => :string
          opt :level, "Log level.", :type    => :string,
                                    :default => 'info'
          opt :name, "Name of heirloom.", :type => :string
          opt :output, "Location to download Heirloom.", :type => :string
          opt :region, "Region to download artifact.", :type    => :string,
                                                       :default => 'us-west-1'
        end
      end
    end
  end
end
