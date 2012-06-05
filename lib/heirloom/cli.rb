require 'trollop'

module Heirloom
  module CLI
    def self.start
      @opts = Trollop::options do
        banner <<-EOS
build and manage artifacts

Usage:

heirloom [options] build
heirloom list
EOS
        opt :help, "Display Help"
        opt :class, "Class of artifact.  This should match the SCM repo", :type => :string
        opt :dir, "Directory which contains git repo", :type => :string
        opt :prefix, "Bucket prefix", :type => :string
        opt :sha, "Git Sha", :type => :string
      end

      cmd = ARGV.shift

      case cmd
      when 'build'
        raise 'Missing required args' unless @opts[:sha] && @opts[:class]
        h = Heirloom.new :heirloom_type => @opts[:class],
                         :source_dir => @opts[:dir] ||= ".",
                         :prefix => @opts[:prefix]

        h.build_and_upload_to_s3(:sha => @opts[:sha])
      when 'list'
        Heirloom.list.each do |a|
          puts a.to_yaml
        end
      when 'info'
        raise 'Missing required args' unless @opts[:sha] && @opts[:class]
        puts Heirloom.info(:class => @opts[:class], :sha => @opts[:sha]).to_yaml
      when 'delete'
        raise 'Missing required args' unless @opts[:sha] && @opts[:class]
        puts Heirloom.delete(:class => @opts[:class], :sha => @opts[:sha]).to_yaml
        puts "!!Make sure to manualy delete any artifacts from S3!!!"
      else
        puts "Unkown command: '#{cmd}'."
      end
    end
  end
end
