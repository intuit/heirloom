require 'tempfile'

module Heirloom

  class Directory

    attr_reader :local_build

    def initialize(args)
      @config = args[:config]
      @exclude = args[:exclude]
      @path = args[:path]
      @logger = @config.logger
    end

    def build_artifact_from_directory
      @local_build = Tempfile.new('archive.tar.gz').path

      @logger.info "Building Heirloom '#{@local_build}' from '#{@path}'."
      @logger.info "Excluding #{@exclude.to_s}."
      @logger.info "Adding #{files_to_pack}."

      build_archive
    end

    private

    def build_archive
      command = "cd #{@path} && tar czf #{@local_build} #{files_to_pack}"
      @logger.info "Archiving with: `#{command}`"
      output = `#{command}`
      @logger.debug "Exited with status: '#{$?.exitstatus}' ouput: '#{output}'"
      $?.success?
    end

    def files_to_pack
      (Dir.entries(@path) - ['.', '..'] - @exclude).join(' ')
    end

  end
end
