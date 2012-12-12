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
        data   = args[:data]
        secret = args[:secret]

        return data unless args[:secret]
        return false unless gpg_in_path?

        encrypted_file = Tempfile.new('archive.tar.gz.enc')
        decrypted_file = Tempfile.new('archive.tar.gz')

        ::File.open(encrypted_file, 'w') { |f| f.write data }

        scrubed_command = "gpg --cipher-algo AES256 --passphrase XXXXXXXX --output #{decrypted_file.path} #{encrypted_file.path}"
        @logger.info "Secret provided. Decrypting with: #{scrubed_command}"

        command = "gpg --cipher-algo AES256 --passphrase #{secret} --output #{decrypted_file.path} #{encrypted_file.path}"
        output = `#{command}`
        @logger.info output
        return false unless $?.success?

        decrypted_file.read
      end

      private

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
