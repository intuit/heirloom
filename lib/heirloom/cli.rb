require 'trollop'

module Heirloom
  module CLI
    def self.start
      @opts = Trollop::options do
        banner <<-EOS

I build and manage artifacts

Usage:

heirloom names
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
      a = Artifact.new :config => nil

      case cmd
      when 'names'
        puts a.names
      when 'list'
        unless @opts[:name]
          puts "Please specify an artifact name."
          puts a.names
          exit 1
        end
        puts a.list :name => @opts[:name]
      when 'show'
        puts a.show(:name => @opts[:name],
                    :id   => @opts[:id]).to_yaml
      when 'build'
        a.build :name           => @opts[:name],
                :id             => @opts[:id],
                :accounts       => @opts[:accounts],
                :bucket_prefix  => @opts[:bucket_prefix],
                :directory      => @opts[:directory],
                :exclude        => @opts[:exclude].split(','),
                :public         => @opts[:public],
                :git            => @opts[:git]
      when 'update'
        a.update :name      => @opts[:name],
                 :id        => @opts[:id],
                 :attribute => @opts[:attribute],
                 :update    => @opts[:update]
      when 'download'
        a.download :name   => @opts[:name],
                   :id     => @opts[:id],
                   :output => @opts[:output],
                   :region => @opts[:region]
      when 'destroy', 'delete'
        a.destroy :name => @opts[:name],
                  :id   => @opts[:id]
      else
        puts "Unkown command: '#{cmd}'."
      end
    end
  end
end
