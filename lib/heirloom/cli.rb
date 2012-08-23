require 'json'
require 'trollop'

require 'heirloom/cli/shared'
require 'heirloom/cli/authorize'
require 'heirloom/cli/upload'
require 'heirloom/cli/setup'
require 'heirloom/cli/list'
require 'heirloom/cli/show'
require 'heirloom/cli/tag'
require 'heirloom/cli/download'
require 'heirloom/cli/destroy'

module Heirloom
  module CLI
    def self.start
      cmd = ARGV.shift

      case cmd
      when 'authorize'
        CLI::Authorize.new.authorize
      when 'destroy', 'delete'
        CLI::Destroy.new.destroy
      when 'download'
        CLI::Download.new.download
      when 'list'
        CLI::List.new.list
      when 'setup'
        CLI::Setup.new.setup
      when 'show'
        CLI::Show.new.show
      when 'update', 'tag'
        CLI::Tag.new.tag
      when 'build', 'upload'
        CLI::Upload.new.upload
      when '-v'
        puts Heirloom::VERSION
      else
        puts "Unkown command: '#{cmd}'." unless cmd == '-h'
        puts "heirloom [authorize|destroy|download|list|setup|show|tag|upload] OPTIONS"
        puts "Append -h for help on specific command."
      end
    end
  end
end
