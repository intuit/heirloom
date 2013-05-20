require 'json'
require 'trollop'

require 'heirloom/cli/formatter'
require 'heirloom/cli/shared'

require 'heirloom/cli/authorize'
require 'heirloom/cli/catalog'
require 'heirloom/cli/cleanup'
require 'heirloom/cli/destroy'
require 'heirloom/cli/download'
require 'heirloom/cli/list'
require 'heirloom/cli/rotate'
require 'heirloom/cli/setup'
require 'heirloom/cli/show'
require 'heirloom/cli/tag'
require 'heirloom/cli/teardown'
require 'heirloom/cli/upload'

module Heirloom
  module CLI
    def self.start
      cmd = ARGV.shift

      case cmd
      when 'authorize'
        CLI::Authorize.new.authorize
      when 'catalog'
        CLI::Catalog.new.all
      when 'cleanup'
        CLI::Cleanup.new.cleanup
      when 'destroy', 'delete'
        CLI::Destroy.new.destroy
      when 'download'
        CLI::Download.new.download
      when 'list'
        CLI::List.new.list
      when 'rotate'
        CLI::Rotate.new.rotate
      when 'setup'
        CLI::Setup.new.setup
      when 'show'
        CLI::Show.new.show
      when 'tag', 'update'
        CLI::Tag.new.tag
      when 'teardown'
        CLI::Teardown.new.teardown
      when 'upload', 'build'
        CLI::Upload.new.upload
      when '-v'
        puts Heirloom::VERSION
      else
        puts "Unkown command: '#{cmd}'." unless cmd == '-h'
        puts "heirloom [authorize|catalog|destroy|download|list|setup|show|tag|teardown|upload] OPTIONS"
        puts "Append -h for help on specific command."
      end
    end
  end
end
