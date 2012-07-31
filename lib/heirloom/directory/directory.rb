require 'tmpdir'

module Heirloom

  class Directory

    attr_writer :local_build

    def initialize(args)
      @config = args[:config]
      @exclude = args[:exclude]
      @path = args[:path]
      @logger = @config.logger
    end

    def build_artifact_from_directory
      random_text = (0...8).map{65.+(Kernel.rand(25)).chr}.join

      unless @local_build
        @local_build = File.join(Dir.tmpdir, random_text + ".tar.gz")
      end

      @logger.info "Building Heirloom '#{@local_build}' from '#{@path}'."
      @logger.info "Excluding #{@exclude.to_s}."
      @logger.info "Adding #{files_to_pack.to_s}."

      build_archive
    end

    private

    def build_archive
      command = "tar czf #{@local_build} #{files_to_pack.join(' ')}"
      @logger.info "Archiving with: `#{command}`"
      output = `#{command}`
      @logger.debug "Exited with status: '#{$?.exitstatus}' ouput: '#{output}'"
      $?.success?
    end

    def files_to_pack
      Dir.entries(@path) - ['.', '..'] - @exclude
    end

  end
end
