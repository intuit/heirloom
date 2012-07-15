module Heirloom
  module CLI
    class Build

      def initialize
        @opts = read_options
        @logger = HeirloomLogger.new :log_level => @opts[:level]
        @heirloom = Heirloom.new :name   => @opts[:name],
                                 :id     => @opts[:id],
                                 :logger => @logger
      end

      def build
        @heirloom.destroy if @heirloom.exists?
                          
        file = @heirloom.build :bucket_prefix  => @opts[:bucket_prefix],
                               :directory      => @opts[:directory],
                               :exclude        => @opts[:exclude].split(','),
                               :public         => @opts[:public],
                               :git            => @opts[:git]

        @heirloom.upload :bucket_prefix    => @opts[:bucket_prefix],
                         :file             => file

        @heirloom.authorize unless @public

        @heirloom.cleanup
      end

      private

      def read_options
        Trollop::options do
          version Heirloom::VERSION
          banner <<-EOS

Build and upload a new Heirloom

Usage:

heirloom build -n NAME -i ID -b BUCKET_PREFIX [-d DIRECTORY] [-p] [-g] [-e DIRECTORIES_TO_EXCLUDE]

EOS
          opt :bucket_prefix, "Bucket prefix which will be combined with region.", :type => :string
          opt :directory, "Source directory of build.", :type    => :string, 
                                                        :default => '.'
          opt :exclude, "Comma spereate list of files or directories to exclude.", :type => :string,
                                                                                   :default => '.git'
          opt :git, "Read git commit information from directory."
          opt :help, "Display Help"
          opt :id, "ID of the heirloom to display.", :type => :string
          opt :level, "Log level.", :type    => :string,
                                    :default => 'info'
          opt :name, "Name of heirloom.", :type => :string
          opt :public, "Set this heirloom as public readable?"
        end
      end

    end
  end
end
