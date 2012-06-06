require 'trollop'

module Heirloom
  module CLI
    def self.start
      @opts = Trollop::options do
        banner <<-EOS
build and manage artifacts

Usage:

heirloom list
heirloom build [options]
heirloom delete [options]
heirloom info [options]
EOS
        opt :help, "Display Help"
        opt :accounts, "CSV list of accounts to authorize", :type => :string
        opt :class, "Class of artifact.  This should match the SCM repo", :type => :string
        opt :dir, "Directory which contains git repo", :type => :string
        opt :prefix, "Bucket prefix", :type => :string
        opt :open, "Is this artifact open to public read?"
        opt :sha, "Git Sha", :type => :string
      end

      cmd = ARGV.shift

      case cmd
      when 'build'
        raise 'Missing required args' unless @opts[:sha] && @opts[:class]
        
        accounts = @opts[:accounts].nil? ? [] : @opts[:accounts].split(',')

        h = Heirloom.new :heirloom_type => @opts[:class],
                         :source_dir => @opts[:dir] ||= ".",
                         :prefix => @opts[:prefix],
                         :open => @opts[:open],
                         :accounts => accounts

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
