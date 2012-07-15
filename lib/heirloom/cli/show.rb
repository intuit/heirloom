module Heirloom
  module CLI
    class Show

      def initialize
        @opts = read_options
        id = @opts[:id] ? @opts[:id] : latest_id
        @heirloom = Heirloom.new :name => @opts[:name],
                                 :id   => id
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

List versions of heirloom.

Usage:

heirloom show -n NAME -i ID

If -i is ommited, latest version is displayed.

EOS
          opt :help, "Display Help"
          opt :name, "Name of artifact.", :type => :string
          opt :id, "ID of the artifact to display.", :type => :string
        end
      end

    end
  end
end
