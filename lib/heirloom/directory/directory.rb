require 'tmpdir'

module Heirloom

  class Directory

    attr_accessor :config, :exclude, :local_build, :path, :logger

    def initialize(args)
      self.config = args[:config]
      self.exclude = args[:exclude]
      self.path = args[:path]
      self.logger = config.logger
    end

    def build_artifact_from_directory
      random_text = (0...8).map{65.+(Kernel.rand(25)).chr}.join

      unless local_build
        self.local_build = File.join(Dir.tmpdir, random_text + ".tar.gz")
      end

      logger.info "Building Heirloom '#{local_build}' from '#{path}'."
      logger.info "Excluding #{exclude.to_s}."
      logger.info "Adding #{files_to_pack.to_s}."

      build_archive local_build, files_to_pack
    end

    private

    def build_archive(local_build, files_to_pack)
      command = "tar czf #{local_build} #{files_to_pack.join(' ')}"
      logger.info "Archiving with: `#{command}`"
      output = `#{command}`
      logger.debug "Exited with status: '#{$?.exitstatus}' ouput: '#{output}'"
      $?.success?
    end
      
    def files_to_pack
      Dir.entries(path) - ['.', '..'] - exclude
    end

  end
end
