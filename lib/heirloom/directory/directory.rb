require 'zlib'
require 'archive/tar/minitar'
require 'tmpdir'

include Archive::Tar

module Heirloom

  class Directory

    def initialize(args)
      @directory = args[:directory]
      @exclude = args[:exclude]
      @logger = args[:logger]
    end

    def build_artifact_from_directory
      random_text = (0...8).map{65.+(rand(25)).chr}.join
      temp_file_name = File.join(Dir.tmpdir, random_text + ".tar.gz")

      @logger.info "Building artifact '#{temp_file_name}' from '#{@directory}'."
      @logger.info "Excluding #{@exclude.to_s}."
      @logger.info "Adding #{files_to_pack.to_s}."

      tgz = Zlib::GzipWriter.new File.open(temp_file_name, 'wb')

      Minitar.pack(files_to_pack, tgz)
      temp_file_name
    end

    private
      
    def files_to_pack
      Dir.entries(@directory) - ['.', '..'] - @exclude
    end


  end
end
