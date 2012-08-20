require 'openssl'
require 'tempfile'

module Heirloom
  module Cipher
    class File

      def initialize(args)
        @config = args[:config]
        @aes = OpenSSL::Cipher::AES256.new(:CBC)
      end

      def encrypt_file(args)
        file   = args[:file]
        secret = args[:secret]
        output = Tempfile.new('archive.tar.gz.enc')
        iv     = @aes.random_iv

        @aes.encrypt
        @aes.iv = iv
        @aes.key = Digest::SHA256.hexdigest secret

        # Need to refactor to be less complex
        # Additionally tests to do fully cover logic
        ::File.open(output,'w') do |enc|
          enc << iv
          ::File.open(file) do |f|
            loop do
              r = f.read(4096)
              break unless r
              enc << @aes.update(r)
            end
          end
          enc << @aes.final
        end
        output.path
      end

    end
  end
end
