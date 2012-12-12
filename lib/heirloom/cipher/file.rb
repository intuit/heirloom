require 'tempfile'
require 'fileutils'

module Heirloom
  module Cipher
    class File

      include Heirloom::Utils::File

      def initialize(args)
        @config = args[:config]
        @logger = @config.logger
      end

      def encrypt_file(args)
        @file           = args[:file]
        @secret         = args[:secret]
        @encrypted_file = Tempfile.new('archive.tar.gz.enc')

        return false unless gpg_in_path?

        scrubed_command = "gpg -c --cipher-algo AES256 --passpharse XXXXXXXX --output #{@encrypted_file.path} #{@file}"
        @logger.info scrubed_command

        command         = "gpg -c --cipher-algo AES256 --passpharse #{@secret} --output #{@encrypted_file.path} #{@file}"
        output          = `#{command}`

        return false unless $?.success?

        replace_file
      end

      private

      def gpg_in_path?
        unless which('gpg')
          @logger.error "gpg not found in path."
          return false
        end
        true
      end

      def replace_file
        FileUtils.mv @encrypted_file.path, @file
        @encrypted_file.close!
      end

    end
  end
end
