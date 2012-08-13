module Heirloom
  module CLI
    class List

      def initialize
        @opts = read_options
        @logger = HeirloomLogger.new :log_level => @opts[:level]
        @config = CLI::Shared.load_config :logger => @logger,
                                          :opts   => @opts
        exit 1 unless CLI::Shared.valid_options? :provided => @opts,
                                                 :required => [:name],
                                                 :logger   => @logger
        @archive = Archive.new :name   => @opts[:name],
                               :config => @config
      end
      
      def list(count = @opts[:count])
        @logger.debug "#{@archive.count} archives found."
        jj @archive.list(count)
      end

      private

      def read_options
        Trollop::options do
          version Heirloom::VERSION
          banner <<-EOS

List versions of archive.

Usage:

heirloom list -n NAME

EOS
          opt :count, "Number of versions to return.", :type    => :integer,
                                                       :default => 10
          opt :help, "Display Help"
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
