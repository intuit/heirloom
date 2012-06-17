require 'zlib'
require 'archive/tar/minitar'
require 'tmpdir'

include Archive::Tar

module Heirloom

  class Directory

    def initialize(args)
      @directory = args[:directory]
      @logger = args[:logger]
    end

    def build_artifact_from_directory
      random_text = (0...8).map{65.+(rand(25)).chr}.join
      temp_file_name = File.join(Dir.tmpdir, random_text + ".tar.gz")

      @logger.info "Building artifact '#{temp_file_name}' from '#{@directory}'."

      tgz = Zlib::GzipWriter.new File.open(temp_file_name, 'wb')
      Minitar.pack(@directory, tgz)
      temp_file_name
    end

  end
end
