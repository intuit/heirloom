module Heirloom

  class ArtifactDownloader

    def initialize(args)
      @config = args[:config]
      @logger = args[:logger]
    end

    def download(args)
      s3_downloader = Downloader::S3.new :config => @config,
                                         :logger => @logger,
                                         :region => args[:region]

      file = s3_downloader.download_file :bucket => get_bucket(args),
                                         :key    => get_key(args)

      @logger = "Writing file to #{args[:output]}."

      File.open(args[:output], 'w') do |local_file|
        local_file.write file
      end
    end

    private

    def get_bucket(args)
      artifact = artifact_reader.show :name   => args[:name],
                                      :id     => args[:id]

      url = artifact["#{args[:region]}-s3-url"].first

      bucket = url.gsub('s3://', '').split('/').first
    end

    def get_key(args)
      artifact = artifact_reader.show :name   => args[:name],
                                      :id     => args[:id]

      url = artifact["#{args[:region]}-s3-url"].first

      bucket = url.gsub('s3://', '').gsub(get_bucket(args), '').slice!(0)
      bucket
    end

    def artifact_reader
      @artifact_reader ||= ArtifactReader.new :config => @config
    end

  end
end
