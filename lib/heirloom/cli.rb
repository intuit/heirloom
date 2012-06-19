require 'trollop'

require 'heirloom/cli/build'
require 'heirloom/cli/list'
require 'heirloom/cli/show'
require 'heirloom/cli/update'
require 'heirloom/cli/download'
require 'heirloom/cli/destroy'

module Heirloom
  module CLI
    def self.start
      @opts = Trollop::options do
        banner <<-EOS

I build and manage artifacts

Usage:

heirloom list -n NAME
heirloom show -n NAME -i ID
heirloom build -n NAME -i ID -b BUCKET_PREFIX [-d DIRECTORY] [-p] [-g]
heirloom download -n NAME -i ID -r REGION -o OUTPUT_FILE
heirloom update -n NAME -i ID -a ATTRIBUTE -u UPDATE
heirloom destroy -n NAME -i ID

EOS
        opt :help, "Display Help"
        opt :attribute, "Attribute to update.", :type => :string
        opt :bucket_prefix, "Bucket prefix which will be combined with region.", :type => :string
        opt :directory, "Source directory of build.", :type    => :string, 
                                                      :default => '.'
        opt :exclude, "Comma spereate list of files or directories to exclude.", :type => :string,
                                                                                 :default => '.git'
        opt :git, "Read git commit information from directory."
        opt :id, "Id of artifact.", :type => :string
        opt :name, "Name of artifact.", :type => :string
        opt :output, "Output download to file.", :type => :string
        opt :public, "Set this artifact as public readable?"
        opt :region, "Region to download artifact.", :type    => :string,
                                                     :default => 'us-west-1'
        opt :update, "Update value of attribute.", :type => :string
      end

      cmd = ARGV.shift
      logger = HeirloomLogger.new

      case cmd
      when 'list'
        cli_list = CLI::List.new :name   => @opts[:name],
                                 :logger => logger
        cli_list.list
      when 'show'
        cli_show = CLI::Show.new :name   => @opts[:name],
                                 :id     => @opts[:id],
                                 :logger => logger
        cli_show.show
      when 'build'
        cli_build = CLI::Build.new :name          => @opts[:name],
                                   :id            => @opts[:id],
                                   :accounts      => @opts[:accounts],
                                   :bucket_prefix => @opts[:bucket_prefix],
                                   :directory     => @opts[:directory],
                                   :exclude       => @opts[:exclude],
                                   :public        => @opts[:public],
                                   :git           => @opts[:git],
                                   :logger        => logger
        cli_build.build
      when 'update'
        cli_update = CLI::Update.new :name      => @opts[:name],
                                     :id        => @opts[:id],
                                     :attribute => @opts[:attribute],
                                     :update    => @opts[:update],
                                     :logger    => logger
        cli_update.update
      when 'download'
        cli_download = CLI::Download.new :name   => @opts[:name],
                                         :id     => @opts[:id],
                                         :output => @opts[:output],
                                         :region => @opts[:region],
                                         :logger => logger
        cli_download.download
      when 'destroy', 'delete'
        cli_destroy = CLI::Destroy.new :name   => @opts[:name],
                                       :id     => @opts[:id],
                                       :logger => logger
        cli_destroy.destroy
      else
        puts "Unkown command: '#{cmd}'."
      end
    end
  end
end
