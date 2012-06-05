require 'trollop'

module Heirloom
  module CLI
    def self.start
      @opts = Trollop::options do
        banner <<-EOS
build and manage artifact

Usage:

heirloom options sha
EOS
        opt :help, "Display Help"
        opt :sha, "Git Sha To Upload"
      end

    cmd = ARGV.shift
    case cmd
    when 'build'
      Heirloom::Heirloom.new(@opts[:sha])
    else
      puts "Unkown command: '#{cmd}'."
    end
  end
end
