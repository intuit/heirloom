module Heirloom
  module CLI
    class Destroy

      include Heirloom::CLI::Shared

      def initialize
        @opts = read_options
        @logger = HeirloomLogger.new :log_level => @opts[:level]
        @config = load_config :logger => @logger,
                              :opts   => @opts

        ensure_valid_options :provided => @opts,
                             :required => [:name, :id],
                             :config   => @config

        ensure_domain_exists :name => @opts[:name], :config => @config

        @name = @opts[:name]
        @id = @opts[:id]
        @archive = Archive.new :name   => @name,
                               :id     => @id,
                               :config => @config
      end
      
      def destroy
        @archive.destroy :keep_domain => false
      end

      private

      def read_options
        Trollop::options do
          version Heirloom::VERSION
          banner <<-EOS

Destroy an archive.

Usage:

heirloom destroy -n NAME -i ID

EOS
          opt :help, "Display Help"
          opt :id, "ID of the archive to display.", :type => :string
          opt :level, "Log level [debug|info|warn|error].", :type    => :string,
                                                            :default => 'info'
          opt :name, "Name of archive.", :type => :string
          opt :aws_access_key, "AWS Access Key ID", :type => :string, 
                                                    :short => :none
          opt :aws_secret_key, "AWS Secret Access Key", :type => :string, 
                                                        :short => :none
        end
      end
    end
  end
end
