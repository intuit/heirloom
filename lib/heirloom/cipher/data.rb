require 'openssl'

module Heirloom
  module Cipher
    class Data

      def initialize(args)
        @config = args[:config]
        @logger = @config.logger
      end

      def decrypt_data(args)
        data   = args[:data]
        secret = args[:secret]

        return data unless args[:secret]

        @logger.info "Secret provided. Decrypting Heirloom."

        @aes = OpenSSL::Cipher::AES256.new(:CBC)
        @aes.decrypt
        @aes.key = Digest::SHA256.hexdigest secret
        @aes.iv = data.slice!(0,16)
        begin
          @aes.update(data) + @aes.final
        rescue OpenSSL::Cipher::CipherError => e
          if e.message == 'wrong final block length'
            @logger.error 'This Heirloom does not appear to be encrypted.'
          end
          @logger.error "Unable to decrypt Heirloom: '#{e.message}'"
          false
        end
      end
    end
  end
end
