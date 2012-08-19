require 'json'
require 'trollop'

require 'heirloom/cli/shared'
require 'heirloom/cli/authorize'
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
      when 'authorize'
        CLI::Authorize.new.authorize
      when 'build'
        CLI::Build.new.build
      when 'destroy', 'delete'
        CLI::Destroy.new.destroy
      when 'download'
        CLI::Download.new.download
      when 'list'
        CLI::List.new.list
      when 'show'
        CLI::Show.new.show
      when 'tag'
        CLI::Update.new.update
      when '-v'
        puts Heirloom::VERSION
      else
        puts "Unkown command: '#{cmd}'." unless cmd == '-h'
        puts "heirloom [list|show|build|authorize|update|download|destroy] OPTIONS"
        puts "Append -h for help on specific command."
      end
    end
  end
end
