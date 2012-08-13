require 'json'

module Heirloom
  module CLI
    class Build

      def initialize
        @opts = read_options
        @logger = HeirloomLogger.new :log_level => @opts[:level]
        @config = CLI::Shared.load_config :logger => @logger,
                                          :opts   => @opts
        exit 1 unless CLI::Shared.valid_options? :provided => @opts, 
                                                 :required => [:name, :id, :regions, 
                                                               :bucket_prefix, 
                                                               :directory],
                                                 :logger   => @logger
        @archive = Archive.new :name   => @opts[:name],
                               :id     => @opts[:id],
                               :config => @config
      end

      def build
        unless @archive.buckets_exist? :bucket_prefix => @opts[:bucket_prefix],
                                       :regions       => @opts[:regions]
          @logger.error "Buckets do no exist in required regions."
          exit 1
        end

        @archive.destroy if @archive.exists?
                          
        build = @archive.build :bucket_prefix   => @opts[:bucket_prefix],
                               :directory       => @opts[:directory],
                               :exclude         => @opts[:exclude].split(','),
                               :git             => @opts[:git]

        if build
          @archive.upload :bucket_prefix   => @opts[:bucket_prefix],
                          :regions         => @opts[:regions],
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

heirloom build -n NAME -i ID -b BUCKET_PREFIX -r REGION [-d DIRECTORY_TO_BUILD] [-p] [-g] [-e DIRECTORIES_TO_EXCLUDE] [-l LOG_LEVEL]

EOS
          opt :bucket_prefix, "Bucket prefix which will be combined with region.\
For example: -b 'test' -r 'us-west-1'  will expect bucket 'test-us-west-1' to be present", :type => :string
          opt :directory, "Source directory of build.", :type    => :string, 
                                                        :default => '.'
          opt :exclude, "Comma spereate list of files or directories to exclude.", :type    => :string,
                                                                                   :default => '.git'
          opt :key, "AWS Access Key ID", :type => :string
          opt :git, "Read git commit information from directory and set as archive attributes."
          opt :help, "Display Help"
          opt :id, "id for archive (when -g specified, assumed to be GIT sha).", :type => :string
          opt :level, "Log level [debug|info|warn|error].", :type    => :string,
                                                            :default => 'info'
          opt :name, "Name of archive.", :type => :string
          opt :public, "Set this archive as public readable?"
          opt :regions, "Region(s) to upload archive.  Can be set multiple times.", :type  => :string,
                                                                                    :multi => true
          opt :secret, "AWS Secret Access Key", :type => :string
        end
      end

    end
  end
end
