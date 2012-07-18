module Heirloom
  module CLI
    class Update

      def initialize
        @opts = read_options
        @logger = HeirloomLogger.new :log_level => @opts[:level]
        @archive = Archive.new :name   => @opts[:name],
                               :id     => @opts[:id],
                               :logger => @logger
      end
      
      def update
        @archive.update :attribute => @opts[:attribute],
                        :value     => @opts[:value]
      end

      private

      def read_options
        Trollop::options do
          version Heirloom::VERSION
          banner <<-EOS

Update an archive's attribute.

Usage:

heirloom update -n NAME -i ID -a ATTRIBUTE_TO_UPDATE -v NEW_VALUE

EOS
          opt :attribute, "Attribute to update.", :type => :string
          opt :help, "Display Help"
          opt :id, "ID of the archive to display.", :type => :string
          opt :level, "Log level.", :type    => :string,
                                    :default => 'info'
          opt :name, "Name of archive.", :type => :string
          opt :value, "New value of attribute.", :type => :string
        end
      end
    end
  end
end
