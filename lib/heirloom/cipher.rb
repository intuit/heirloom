require 'openssl'
require 'tempfile'

module Heirloom
  class Cipher

    def initialize(args)
      @config = args[:config]
      @logger = @config.logger
      @aes = OpenSSL::Cipher::AES256.new(:CBC)
    end

    def decrypt_data(args)
      data   = args[:data]
      secret = args[:secret]

      @aes.decrypt
      @aes.key = secret
      @aes.iv = data.slice!(0,16)
      @aes.update(data) + @aes.final
    end

    def encrypt_file(args)
      file   = args[:file]
      secret = args[:secret]
      output = Tempfile.new('archive.tar.gz.enc')
      iv     = @aes.random_iv

      @aes.encrypt
      @aes.iv = iv
      @aes.key = secret

      File.open(output,'w') do |enc|
        enc << iv
        File.open(file) do |f|
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
