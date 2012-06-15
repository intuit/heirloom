require 'trollop'

module Heirloom
  module CLI
    def self.start
      @opts = Trollop::options do
        banner <<-EOS
I build and manage artifacts

Usage:

heirloom list
heirloom versions -n NAME
heirloom show -n NAME -v VERSION
EOS
        opt :help, "Display Help"
        opt :name, "Name of artifact.", :type => :string
        opt :version, "Version of artifact.", :type => :string
      end

      cmd = ARGV.shift
      a = Artifact.new :config => nil

      case cmd
      when 'list'
        puts a.list
      when 'versions'
        puts a.versions :name => @opts[:name]
      when 'show'
        puts a.show :name => @opts[:name],
                    :version => @opts[:version]
      else
        puts "Unkown command: '#{cmd}'."
      end
    end
  end
end
