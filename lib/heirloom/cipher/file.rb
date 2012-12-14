require 'tempfile'
require 'fileutils'

module Heirloom
  module Cipher
    class File

      include Heirloom::Cipher::Shared

      def initialize(args)
        @config = args[:config]
        @logger = @config.logger
      end

      def encrypt_file(args)
        @file           = args[:file]
        @secret         = args[:secret]
        @encrypted_file = Tempfile.new('archive.tar.gz.enc')

        return false unless gpg_in_path? @logger
        return false unless encrypt

        replace_file
      end

      private

      def encrypt
        @logger.info "Encrypting with: '#{command}'"
        output = `#{command(@secret)}`
        @logger.debug "Encryption output: '#{output}'"
        @logger.error "Encryption failed with output: '#{output}'" unless $?.success?
        $?.success?
      end

      def command(secret="XXXXXXXX")
        "gpg --batch --yes -c --cipher-algo AES256 --passphrase #{secret} --output #{@encrypted_file.path} #{@file} 2>&1"
      end

      def replace_file
        FileUtils.mv @encrypted_file.path, @file
        @encrypted_file.close!
      end

    end
  end
end
