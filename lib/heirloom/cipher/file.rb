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
        return false unless encrypt

        replace_file
      end

      private

      def encrypt
        @logger.info "Encrypting with: '#{scrubed_command}'"
        output = `#{command}`
        @logger.debug "Encryption output: '#{output}'"
        $?.success?
        if $?.success?
          true
        else
          @logger.error "Encryption failed with output: '#{output}'"
          false
        end
      end

      def scrubed_command 
        "gpg --batch --yes -c --cipher-algo AES256 --passphrase XXXXXXXX --output #{@encrypted_file.path} #{@file} 2>&1"
      end

      def command
        "gpg --batch --yes -c --cipher-algo AES256 --passphrase #{@secret} --output #{@encrypted_file.path} #{@file} 2>&1"
      end

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
