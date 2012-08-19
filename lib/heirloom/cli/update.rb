module Heirloom
  module CLI
    class Update

      include Heirloom::CLI::Shared

      def initialize
        @opts = read_options
        @logger = HeirloomLogger.new :log_level => @opts[:level]
        @config = load_config :logger => @logger,
                              :opts   => @opts

        ensure_valid_options :provided => @opts,
                             :required => [:name, :id, :attribute, :updated_value],
                             :config   => @config

        ensure_domain_exists :name => @opts[:name], :config => @config

        @archive = Archive.new :name   => @opts[:name],
                               :id     => @opts[:id],
                               :config => @config
      end
      
      def update
        @archive.update :attribute  => @opts[:attribute],
                        :value      => @opts[:updated_value]
      end

      private

      def read_options
        Trollop::options do
          version Heirloom::VERSION
          banner <<-EOS

Update an archive's attribute.

Usage:

heirloom update -n NAME -i ID -a ATTRIBUTE_TO_UPDATE -u UPDATED_VALUE

EOS
          opt :attribute, "Attribute to update.", :type => :string
          opt :help, "Display Help"
          opt :id, "ID of the archive to display.", :type => :string
          opt :level, "Log level [debug|info|warn|error].", :type    => :string,
                                                            :default => 'info'
          opt :name, "Name of archive.", :type => :string
          opt :updated_value, "Updated value of attribute.", :type => :string
          opt :aws_access_key, "AWS Access Key ID", :type => :string, 
                                                    :short => :none
          opt :aws_secret_key, "AWS Secret Access Key", :type => :string, 
                                                        :short => :none
        end
      end
    end
  end
end
