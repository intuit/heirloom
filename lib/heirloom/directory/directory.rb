require 'zlib'
require 'archive/tar/minitar'
require 'tmpdir'

include Archive::Tar

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
      random_text = (0...8).map{65.+(rand(25)).chr}.join

      unless local_build
        self.local_build = File.join(Dir.tmpdir, random_text + ".tar.gz")
      end

      logger.info "Building Heirloom '#{local_build}' from '#{path}'."
      logger.info "Excluding #{exclude.to_s}."
      logger.info "Adding #{files_to_pack.to_s}."

      tgz = Zlib::GzipWriter.new File.open(local_build, 'wb')

      Minitar.pack(files_to_pack, tgz)
    end

    private
      
    def files_to_pack
      Dir.entries(path) - ['.', '..'] - exclude
    end

  end
end
