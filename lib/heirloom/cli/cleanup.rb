module Heirloom
  module CLI
    class Cleanup

      include Heirloom::CLI::Shared

      def initialize
        load_settings!
        Heirloom.log_level = Heirloom.config.log_level

        unless Heirloom.config.name?
          Heirloom.log.error "Option 'name' required but not specified"
          exit 1
        end
      end
      
      def cleanup
        cat = Heirloom::Catalog.new :name => Heirloom.config.name, :config => Heirloom.config
        cat.cleanup :num_to_keep => Heirloom.config.keep
      rescue Heirloom::Exceptions::CleanupFailed => e
        Heirloom.log.error e.message
        exit 1
      end

      private

      def load_settings!
        Heirloom.load_config! read_options
      end

      def read_options
        Trollop::options do
          version Heirloom::VERSION
          banner <<-EOS

Delete old heirlooms.  Will not delete any IDs tagged with 'preserve': true.

Usage:

heirloom cleanup -n NAME -k 10

EOS
          opt :attribute, "Attribute to update.", :type => :string
          opt :help, "Display Help"
          opt :id, "ID of the Heirloom to tag.", :type => :string
          opt :log_level, "Log level [debug|info|warn|error].", :type    => :string,
                                                                :default => 'info'
          opt :metadata_region, "AWS region to store Heirloom metadata.", :type    => :string,   
                                                                          :default => 'us-west-1'
          opt :name, "Name of Heirloom.", :type => :string
          opt :keep, "Number of unpreserved heirlooms to keep.", :default => 100

          opt :aws_access_key, "AWS Access Key ID", :type  => :string, 
                                                    :short => :none
          opt :aws_secret_key, "AWS Secret Access Key", :type  => :string, 
                                                        :short => :none
          opt :environment, "Environment (defined in ~/.heirloom.yml)", :type => :string
        end
      end
    end
  end
end
