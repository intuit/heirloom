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
heirloom build -n NAME -i ID [-d DIRECTORY] [-p] [-g]
heirloom update -n NAME -i ID -a ATTRIBUTE -u UPDATE
heirloom destroy -n NAME -i ID

EOS
        opt :help, "Display Help"
        opt :attribute, "Attribute to update.", :type => :string
        opt :directory, "Source directory of build.", :type => :string, 
                                                      :default => '.'
        opt :git, "Read git commit information from directory."
        opt :id, "Id of artifact.", :type => :string
        opt :name, "Name of artifact.", :type => :string
        opt :public, "Set this artifact as public readable?"
        opt :update, "Update value of attribute.", :type => :string
      end

      cmd = ARGV.shift
      a = Artifact.new :config => nil

      case cmd
      when 'names'
        puts a.names
      when 'list'
        puts a.list :name => @opts[:name]
      when 'show'
        puts a.show(:name => @opts[:name],
                    :id   => @opts[:id]).to_yaml
      when 'build'
        a.build :name      => @opts[:name],
                :id        => @opts[:id],
                :accounts  => @opts[:accounts],
                :directory => @opts[:directory],
                :public    => @opts[:public],
                :git       => @opts[:git]
      when 'update'
        a.update :name      => @opts[:name],
                 :id        => @opts[:id],
                 :attribute => @opts[:attribute],
                 :update    => @opts[:update]
      when 'destroy', 'delete'
        a.destroy :name => @opts[:name],
                  :id   => @opts[:id]
      else
        puts "Unkown command: '#{cmd}'."
      end
    end
  end
end
