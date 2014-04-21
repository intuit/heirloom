module Heirloom
  module CLI
    class Destroy

      include Heirloom::CLI::Shared

      def self.command_summary
        'Destroy an Heirloom'
      end

      def initialize
        @opts = read_options
        @logger = HeirloomLogger.new :log_level => @opts[:level]
        @config = load_config :logger => @logger,
                              :opts   => @opts

        ensure_valid_options :provided => @opts,
                             :required => [:name, :id],
                             :config   => @config
        ensure_valid_metadata_region @config
        ensure_domain_exists :name => @opts[:name], :config => @config

        @name = @opts[:name]
        @id = @opts[:id]
        @archive = Archive.new :name   => @name,
                               :id     => @id,
                               :config => @config
        ensure_archive_exists :archive => @archive,
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

#{Destroy.command_summary}.

Usage:

heirloom destroy -n NAME -i ID

EOS
          opt :help, "Display Help"
          opt :id, "ID of the Heirloom to display.", :type => :string
          opt :level, "Log level [debug|info|warn|error].", :type    => :string,
                                                            :default => 'info'
          opt :metadata_region, "AWS region to store Heirloom metadata.", :type => :string
          opt :name, "Name of Heirloom.", :type => :string
          opt :aws_access_key, "AWS Access Key ID", :type => :string, 
                                                    :short => :none
          opt :aws_secret_key, "AWS Secret Access Key", :type => :string, 
                                                        :short => :none
          opt :use_iam_profile, "Use IAM EC2 Profile", :short => :none
          opt :environment, "Environment (defined in heirloom config file)", :type => :string
        end
      end
    end
  end
end
