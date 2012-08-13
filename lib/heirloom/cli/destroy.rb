module Heirloom
  module CLI
    class Destroy

      include Heirloom::CLI::Shared

      def initialize
        @opts = read_options
        @logger = HeirloomLogger.new :log_level => @opts[:level]
        @config = load_config :logger => @logger,
                              :opts   => @opts

        exit 1 unless valid_options? :provided => @opts,
                                     :required => [:name, :id],
                                     :logger   => @logger
        @name = @opts[:name]
        @id = @opts[:id]
        @archive = Archive.new :name   => @name,
                               :id     => @id,
                               :config => @config
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
          opt :key, "AWS Access Key ID", :type => :string
          opt :level, "Log level [debug|info|warn|error].", :type    => :string,
                                                            :default => 'info'
          opt :name, "Name of archive.", :type => :string
          opt :secret, "AWS Secret Access Key", :type => :string
        end
      end
    end
  end
end
