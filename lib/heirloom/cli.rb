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
      cmd = ARGV.shift

      case cmd
      when 'list'
        CLI::List.new.list
      when 'show'
        CLI::Show.new.show
      when 'build'
        CLI::Build.new.build
      when 'update'
        CLI::Update.new.update
      when 'download'
        CLI::Download.new.download
      when 'destroy', 'delete'
        CLI::Destroy.new.destroy
      else
        puts "Unkown command: '#{cmd}'."
      end
    end
  end
end
