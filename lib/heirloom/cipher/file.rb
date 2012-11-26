require 'openssl'
require 'tempfile'
require 'fileutils'

module Heirloom
  module Cipher
    class File

      def initialize(args)
        @config = args[:config]
        @aes = OpenSSL::Cipher::AES256.new(:CBC)
      end

      def encrypt_file(args)
        @file           = args[:file]
        @encrypted_file = Tempfile.new('archive.tar.gz.enc')
        secret          = args[:secret]
        iv              = @aes.random_iv

        @aes.encrypt
        @aes.iv = iv
        @aes.key = Digest::SHA256.hexdigest secret

        # Need to refactor to be less complex
        # Additionally tests to do fully cover logic
        ::File.open(@encrypted_file,'w') do |enc|
          enc << iv
          ::File.open(@file) do |f|
            loop do
              r = f.read(4096)
              break unless r
              enc << @aes.update(r)
            end
          end
          enc << @aes.final
        end

        replace_file
      end

      private

      def replace_file
        FileUtils.mv @encrypted_file.path, @file
        @encrypted_file.close!
      end

    end
  end
end
