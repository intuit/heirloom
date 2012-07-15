module Heirloom
  module CLI
    class Destroy

      def initialize
        @opts = read_options
        @name = @opts[:name]
        @id = @opts[:id]
        @heirloom = Heirloom.new :name => @name,
                                 :id   => @id
      end
      
      def destroy
        @heirloom.destroy
      end

      private

      def read_options
        Trollop::options do
          version Heirloom::VERSION
          banner <<-EOS

Destroy an Heirloom

Usage:

heirloom destroy -n NAME -i ID [-l LOG_LEVEL]

EOS
          opt :help, "Display Help"
          opt :id, "ID of the heirloom to display.", :type => :string
          opt :level, "Log level.", :type    => :string,
                                    :default => 'info'
          opt :name, "Name of heirloom.", :type => :string
        end
      end
    end
  end
end
