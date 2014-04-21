module Heirloom

  class Downloader

    def initialize(args)
      @config = args[:config]
      @name   = args[:name]
      @id     = args[:id]
      @logger = @config.logger
    end

    def download(args)
      @region        = args[:region]
      @bucket_prefix = args[:bucket_prefix]
      @secret        = args[:secret]
      extract        = args[:extract]
      output         = args[:output] ||= './'

      @logger.info "Downloading s3://#{bucket}/#{key} from #{@region}."

      s3_downloader = Downloader::S3.new :config => @config,
                                         :logger => @logger,
                                         :region => @region

      raw_archive = s3_downloader.download_file :bucket => bucket,
                                                :key    => key

      return false unless raw_archive

      archive = cipher_data.decrypt_data :data   => raw_archive,
                                         :secret => @secret

      return false unless archive

      return false unless writer.save_archive :archive => archive, 
                                              :output  => output,
                                              :file    => file,
                                              :extract => extract

      @logger.info "Download complete."

      output
    end

    private

    def file
      "#{@id}.tar.gz"
    end

    def key
      @secret ? "#{@name}/#{@id}.tar.gz.gpg" : "#{@name}/#{@id}.tar.gz"
    end

    def bucket
      "#{@bucket_prefix}-#{@region}"
    end

    def writer
      @writer ||= Writer.new :config => @config
    end

    def cipher_data
      @cipher_data ||= Cipher::Data.new :config => @config
    end
  end
end
