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

    def build_artifact_from_directory(args)
      @secret = args[:secret]

      @local_build = Tempfile.new('archive.tar.gz').path

      @logger.debug "Building Heirloom '#{@local_build}' from '#{@path}'."
      @logger.debug "Excluding #{@exclude.to_s}."
      @logger.debug "Adding #{files_to_pack}."

      return build_archive unless @secret

      build_encrypted_archive 
    end

    private

    def build_archive
      command = "cd #{@path} && tar czf #{@local_build} #{files_to_pack}"
      @logger.info "Archiving with: `#{command}`"
      output = `#{command}`
      @logger.debug "Exited with status: '#{$?.exitstatus}' ouput: '#{output}'"
      $?.success?
    end

    def build_encrypted_archive
      return false unless build_archive
      @logger.info "Secret provided. Encrypting."
      @local_build = cipher_file.encrypt_file :file   => @local_build,
                                              :secret => @secret
    end

    def files_to_pack
      (Dir.entries(@path) - ['.', '..'] - @exclude).join(' ')
    end

    def cipher_file
      @cipher_file = Heirloom::Cipher::File.new :config => @config
    end

  end
end
