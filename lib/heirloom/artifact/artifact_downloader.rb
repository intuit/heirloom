module Heirloom

  class ArtifactDownloader

    attr_accessor :config, :id, :name, :logger

    def initialize(args)
      self.config = args[:config]
      self.name = args[:name]
      self.id = args[:id]
      self.logger = config.logger
    end

    def download(args)
      region = args[:region]

      s3_downloader = Downloader::S3.new :config => config,
                                         :logger => logger,
                                         :region => region

      bucket = artifact_reader.get_bucket :region => region
      key = artifact_reader.get_key :region => region

      logger.info "Downloading s3://#{bucket}/#{key} from #{region}."

      file = s3_downloader.download_file :bucket => bucket,
                                         :key    => key

      output = args[:output] ||= "./#{key.split('/').last}"

      logger.info "Writing file to #{output}."

      File.open(output, 'w') do |local_file|
        local_file.write file
      end

      logger.info "Download complete."
    end

    private

    def artifact_reader
      @artifact_reader ||= ArtifactReader.new :config => config,
                                              :name   => name,
                                              :id     => id
    end

  end
end
