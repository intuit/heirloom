require 'hashie'
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
        puts "Unknown command: '#{cmd}'." unless cmd == '-h'
        usage
      end
    end

    def self.usage
      puts ''
      puts 'Usage: heirloom command [options]'
      puts ''
      puts 'Append -h for help on specific command.'
      puts ''
      puts 'Commands:'
      commands.each do |cmd|
        $stdout.printf "    %-#{length_of_longest_command}s      %s\n",
                       cmd.command_name,
                       cmd.command_summary
      end
    end

    def self.commands
      return @commands if @commands
      klasses = Heirloom::CLI.constants.reject { |c| [:Shared, :Formatter].include?(c) }
      @commands = klasses.map do |klass|
        Hashie::Mash.new.tap do |h|
          h[:command_name]    = klass.downcase
          h[:command_summary] = Heirloom::CLI.const_get(klass).command_summary rescue 'No summary available'
        end
      end
    end

    def self.length_of_longest_command
      @length ||= commands.map { |c| c.command_name.length }.max
    end

  end
end
