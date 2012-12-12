require 'tempfile'

module Heirloom
  module Cipher
    class Data

      include Heirloom::Utils::File

      def initialize(args)
        @config = args[:config]
        @logger = @config.logger
      end

      def decrypt_data(args)
        @data   = args[:data]
        @secret = args[:secret]

        return @data unless args[:secret]
        return false unless gpg_in_path?

        @encrypted_file = Tempfile.new('archive.tar.gz.gpg')
        @decrypted_file = Tempfile.new('archive.tar.gz')

        ::File.open(@encrypted_file, 'w') { |f| f.write @data }

        decrypt
      end

      private

      def decrypt
        @logger.info "Secret provided. Decrypting with: '#{scrubed_command}'"
        output = `#{command}`
        @logger.debug "Decryption output: '#{output}'"

        if $?.success?
          @decrypted_file.read 
        else
          @logger.error "Decryption failed with output: '#{output}'"
          false
        end
      end

      def scrubed_command 
        "gpg --batch --yes --cipher-algo AES256 --passphrase XXXXXXXX --output #{@decrypted_file.path} #{@encrypted_file.path} 2>&1"
      end

      def command 
        "gpg --batch --yes --cipher-algo AES256 --passphrase #{@secret} --output #{@decrypted_file.path} #{@encrypted_file.path} 2>&1"
      end

      def gpg_in_path?
        unless which('gpg')
          @logger.error "gpg not found in path."
          return false
        end
        true
      end

    end
  end
end
