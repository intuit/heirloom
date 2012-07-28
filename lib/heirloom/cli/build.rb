require 'json'

module Heirloom
  module CLI
    class Build

      def initialize
        @opts = read_options
        @logger = HeirloomLogger.new :log_level => @opts[:level]
        exit 1 unless CLI::Shared.valid_options? :provided => @opts, 
                                                 :required => [:name, :id, :regions, 
                                                               :bucket_prefix, 
                                                               :directory],
                                                 :logger   => @logger
        @archive = Archive.new :name   => @opts[:name],
                               :id     => @opts[:id],
                               :logger => @logger
      end

      def build
        unless @archive.buckets_exist? :bucket_prefix => @opts[:bucket_prefix],
                                       :regions       => @opts[:regions]
          @logger.error "Buckets do no exist in required regions."
          exit 1
        end

        @archive.destroy if @archive.exists?
                          
        archive_file = @archive.build :bucket_prefix   => @opts[:bucket_prefix],
                                      :directory       => @opts[:directory],
                                      :exclude         => @opts[:exclude].split(','),
                                      :git             => @opts[:git]

        @archive.upload :bucket_prefix   => @opts[:bucket_prefix],
                        :regions         => @opts[:regions],
                        :public_readable => @opts[:public],
                        :file            => archive_file

        @archive.cleanup
      end

      private

      def read_options
        Trollop::options do
          version Heirloom::VERSION
          banner <<-EOS

Build and upload a new archive.

Usage:

heirloom build -n NAME -i ID -b BUCKET_PREFIX [-d DIRECTORY] [-p] [-g] [-e DIRECTORIES_TO_EXCLUDE]

EOS
          opt :bucket_prefix, "Bucket prefix which will be combined with region.", :type => :string
          opt :directory, "Source directory of build.", :type    => :string, 
                                                        :default => '.'
          opt :exclude, "Comma spereate list of files or directories to exclude.", :type    => :string,
                                                                                   :default => '.git'
          opt :git, "Read git commit information from directory."
          opt :help, "Display Help"
          opt :id, "ID of the archive to display.", :type => :string
          opt :level, "Log level.", :type    => :string,
                                    :default => 'info'
          opt :name, "Name of archive.", :type => :string
          opt :public, "Set this archive as public readable?"
          opt :regions, "Region(s) to upload archive.  Can be set multiple times.", :type  => :string,
                                                                                    :multi => true
        end
      end

    end
  end
end
