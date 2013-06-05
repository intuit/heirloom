module Heirloom
  module CLI
    class Show

      include Heirloom::CLI::Shared

      def self.command_summary
        'Show Heirloom'
      end

      def initialize
        @opts = read_options
        @logger = HeirloomLogger.new :log_level => @opts[:level]
        @config = load_config :logger => @logger,
                              :opts   => @opts

        ensure_valid_options :provided => @opts,
                             :required => [:name],
                             :config   => @config
        ensure_valid_region :region => @opts[:metadata_region],
                            :config => @config
        ensure_domain_exists :name   => @opts[:name], 
                             :config => @config

        # Can't use fetch as Trollop sets :id to nil
        id = @opts[:id] || (latest_id :name   => @opts[:name],
                                      :config => @config)

        @archive = Archive.new :name   => @opts[:name],
                               :config => @config,
                               :id     => id
        ensure_archive_exists :archive => @archive,
                              :config  => @config
      end
      
      def show
        data = @archive.show
        if @opts[:json]
          jj data
        else
          formatter = Heirloom::CLI::Formatter::Show.new
          puts formatter.format :attributes => data,
                                :all        => @opts[:all]
        end
      end

      private

      def read_options
        Trollop::options do
          version Heirloom::VERSION
          banner <<-EOS

#{Show.command_summary}.

Usage:

heirloom show -n NAME -i ID

If -i is ommited, latest ID is displayed.

EOS
          opt :help, "Display Help"
          opt :all, "Display all attributes (includes internal heirloom settings)."
          opt :id, "ID of the Heirloom to display.", :type => :string
          opt :json, "Display output as raw JSON."
          opt :level, "Log level [debug|info|warn|error].", :type    => :string,
                                                            :default => 'info'
          opt :metadata_region, "AWS region to store Heirloom metadata.", :type    => :string,   
                                                                          :default => 'us-west-1'
          opt :name, "Name of Heirloom.", :type => :string
          opt :aws_access_key, "AWS Access Key ID", :type => :string, 
                                                    :short => :none
          opt :aws_secret_key, "AWS Secret Access Key", :type => :string, 
                                                        :short => :none
          opt :use_iam_profile, "Use IAM EC2 Profile", :short => :none
          opt :environment, "Environment (defined in ~/.heirloom.yml)", :type => :string
        end
      end

    end
  end
end
