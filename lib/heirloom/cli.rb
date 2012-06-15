require 'trollop'

module Heirloom
  module CLI
    def self.start
      @opts = Trollop::options do
        banner <<-EOS
I build and manage artifacts

Usage:

heirloom list
heirloom build [options]
heirloom delete [options]
heirloom info [options]
EOS
        opt :help, "Display Help"
        opt :accounts, "CSV list of AWS accounts to authorize.", :type => :string
        opt :bucket, "Bucket prefix.", :type => :string
        opt :name, "Name of artifact.", :type => :string
        opt :dir, "Directory which contains git repo to package.", :type => :string
        opt :public, "Is this artifact public read?"
        opt :sha, "Git sha to rebase to and package.", :type => :string
      end

      cmd = ARGV.shift
      a = Artifact.new :config => nil

      case cmd
      when 'list'
        puts a.list :name => @opts[:name]
      else
        puts "Unkown command: '#{cmd}'."
      end
    end
  end
end
