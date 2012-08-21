module Heirloom
  module CLI
    class Upload

      include Heirloom::CLI::Shared

      def initialize
        @opts = read_options
        @logger = HeirloomLogger.new :log_level => @opts[:level]
        @config = load_config :logger => @logger,
                              :opts   => @opts

        ensure_valid_options :provided => @opts, 
                             :required => [:name, :id, :region, 
                                           :base, :directory],
                             :config   => @config

        @archive = Archive.new :name   => @opts[:name],
                               :id     => @opts[:id],
                               :config => @config
      end

      def upload
        ensure_directory :path => @opts[:directory], :config => @config
        ensure_valid_secret :secret => @opts[:secret], :config => @config

        @archive.setup :regions       => @opts[:region],
                       :bucket_prefix => @opts[:base]

        @archive.destroy :keep_domain => true if @archive.exists?
                          
        build = @archive.build :base       => @opts[:base],
                               :directory  => @opts[:directory],
                               :exclude    => @opts[:exclude],
                               :git        => @opts[:git],
                               :secret     => @opts[:secret]

        unless build
          @logger.error "Build failed."
          exit 1
        end

        @archive.upload :bucket_prefix   => @opts[:base],
                        :regions         => @opts[:region],
                        :public_readable => @opts[:public],
                        :file            => build
      end

      private

      def read_options
        Trollop::options do
          version Heirloom::VERSION
          banner <<-EOS

Upload a directory to Heirloom.

Usage:

heirloom upload -n NAME -i ID -b BASE -r REGION1 -r REGION2 -d DIRECTORY_TO_UPLOAD

EOS
          opt :base, "Base prefix which will be combined with region. \
For example: -b 'test' -r 'us-west-1'  will expect bucket 'test-us-west-1' \
to be present", :type => :string
          opt :directory, "Source directory of build.", :type  => :string
          opt :exclude, "File(s) or directorie(s) to exclude. \
Can be specified multiple times.", :type  => :string, :multi => true
          opt :git, "Read git commit information from directory and set as archive attributes."
          opt :help, "Display Help"
          opt :id, "ID for archive (when -g specified, assumed to be GIT sha).", :type => :string
          opt :level, "Log level [debug|info|warn|error].", :type    => :string,
                                                            :default => 'info'
          opt :name, "Name of archive.", :type => :string
          opt :public, "Set this archive as public readable?"
          opt :region, "Region(s) to upload archive. \
Can be specified multiple times.", :type  => :string, :multi => true
          opt :secret, "Encrypt the archive with given secret.", :type => :string
          opt :aws_access_key, "AWS Access Key ID", :type => :string, 
                                                    :short => :none
          opt :aws_secret_key, "AWS Secret Access Key", :type => :string, 
                                                        :short => :none
        end
      end

    end
  end
end
