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
      key = get_key :region => region, :base => base

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
      base = args[:base]
      region = args[:region]

      if base
        "#{base}-#{region}"
      else
        reader.get_bucket :region => region
      end
    end

    def get_key(args)
      base = args[:base]
      region = args[:region]

      if base
        "#{@name}/#{@id}.tar.gz"
      else
        reader.get_key :region => region
      end
    end

    def reader
      @reader ||= Reader.new :config => @config,
                             :name   => @name,
                             :id     => @id
    end

  end
end
