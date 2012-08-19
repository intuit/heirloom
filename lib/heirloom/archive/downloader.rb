module Heirloom

  class Downloader

    def initialize(args)
      @config = args[:config]
      @name = args[:name]
      @id = args[:id]
      @logger = @config.logger
    end

    def download(args)
      @region = args[:region]
      @base_prefix = args[:base_prefix]
      extract = args[:extract]
      output = args[:output] ||= './'

      s3_downloader = Downloader::S3.new :config => @config,
                                         :logger => @logger,
                                         :region => @region

      @logger.info "Downloading s3://#{bucket}/#{key} from #{@region}."
      raw_archive = s3_downloader.download_file :bucket => bucket,
                                                :key    => key

      @logger.info "Decrypting archive."
      archive = cipher.decrypt_data :data   => raw_archive, 
                                    :secret => '12345678901234567890123456789012'

      if extract
        extracter = Extracter.new :config => @config
        extracter.extract :archive => archive, :output => output
      else
        output_file = File.join output, file
        @logger.info "Writing archive to '#{output_file}'."
        File.open(output_file, 'w') { |local_file| local_file.write archive }
      end

      @logger.info "Download complete."
    end

    private

    def file 
      "#{@id}.tar.gz"
    end

    def key
      "#{@name}/#{file}"
    end

    def bucket
      "#{@base_prefix}-#{@region}"
    end

    def cipher
      @cipher = Heirloom::Cipher.new :config => @config
    end
  end
end
