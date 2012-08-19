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

        return data unless secret

        @logger.info "Secret provided. Decrypting archive."

        @aes = OpenSSL::Cipher::AES256.new(:CBC)
        @aes.decrypt
        @aes.key = secret
        @aes.iv = data.slice!(0,16)
        begin
          @aes.update(data) + @aes.final
        rescue OpenSSL::Cipher::CipherError
          false
        end
      end
    end
  end
end
