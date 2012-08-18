module Heirloom
  module CLI
    class Build

      include Heirloom::CLI::Shared

      def initialize
        @opts = read_options
        @logger = HeirloomLogger.new :log_level => @opts[:level]
        @config = load_config :logger => @logger,
                              :opts   => @opts

        ensure_valid_options :provided => @opts, 
                             :required => [:name, :id, :region, 
                                           :base_prefix, :directory],
                             :config   => @config

        @archive = Archive.new :name   => @opts[:name],
                               :id     => @opts[:id],
                               :config => @config
      end

      def build
        unless @archive.buckets_exist? :bucket_prefix => @opts[:base_prefix],
                                       :regions       => @opts[:region]
          @logger.error "Buckets do no exist in required regions."
          exit 1
        end

        ensure_directory :path => @opts[:directory], :config => @config

        @archive.destroy if @archive.exists?
                          
        build = @archive.build :bucket_prefix => @opts[:base_prefix],
                               :directory     => @opts[:directory],
                               :exclude       => @opts[:exclude],
                               :git           => @opts[:git]

        if build
          @archive.upload :bucket_prefix   => @opts[:base_prefix],
                          :regions         => @opts[:region],
                          :public_readable => @opts[:public],
                          :file            => build
          @archive.cleanup
        else
          @logger.error "Build failed."
          exit 1
        end
      end

      private

      def read_options
        Trollop::options do
          version Heirloom::VERSION
          banner <<-EOS

Build and upload a new archive.

Usage:

heirloom build -n NAME -i ID -b BASE_PREFIX -r REGION1 -r REGION2 -d DIRECTORY_TO_BUILD

EOS
          opt :base_prefix, "Base bucket prefix which will be combined with region. \
For example: -b 'test' -r 'us-west-1'  will expect bucket 'test-us-west-1' to be present", :type => :string
          opt :directory, "Source directory of build.", :type  => :string
          opt :exclude, "File(s) or directorie(s) to exclude. \
Can be specified multiple times.", :type  => :string, 
                                   :multi => true
          opt :key, "AWS Access Key ID", :type => :string
          opt :git, "Read git commit information from directory and set as archive attributes."
          opt :help, "Display Help"
          opt :id, "ID for archive (when -g specified, assumed to be GIT sha).", :type => :string
          opt :level, "Log level [debug|info|warn|error].", :type    => :string,
                                                            :default => 'info'
          opt :name, "Name of archive.", :type => :string
          opt :public, "Set this archive as public readable?"
          opt :region, "Region(s) to upload archive.  Can be specified multiple times.", :type  => :string,
                                                                                         :multi => true
          opt :secret, "AWS Secret Access Key", :type => :string
        end
      end

    end
  end
end
