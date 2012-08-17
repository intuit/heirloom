module Heirloom

  class Downloader

    def initialize(args)
      @config = args[:config]
      @name = args[:name]
      @id = args[:id]
      @logger = @config.logger
    end

    def download(args)
      region = args[:region]
      base = args[:base]

      s3_downloader = Downloader::S3.new :config => @config,
                                         :logger => @logger,
                                         :region => region

      bucket = get_bucket :region => region, :base => base

      @logger.info "Downloading s3://#{bucket}/#{key} from #{region}."

      file = s3_downloader.download_file :bucket => bucket,
                                         :key    => key

      output = args[:output] ||= "./#{key.split('/').last}"

      @logger.info "Writing file to #{output}."

      File.open(output, 'w') do |local_file|
        local_file.write file
      end

      @logger.info "Download complete."
    end

    private

    def get_bucket(args)
      "#{args[:base]}-#{args[:region]}"
    end

    def key
      "#{@name}/#{@id}.tar.gz"
    end

  end
end
