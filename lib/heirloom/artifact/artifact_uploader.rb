module Heirloom

  class ArtifactUploader

    def initialize(args)
      @config = args[:config]
      @logger = args[:logger]
    end

    def upload(args)
      id = args[:id]
      file = args[:file]
      key_folder = args[:name]
      key_name = "#{id}.tar.gz"
      name = args[:name]
      public_readable = args[:public_readable]

      @config.regions.each do |region|
        bucket = "#{@config.bucket_prefix}-#{region}"

        s3_uploader = Uploader::S3.new :config => @config,
                                       :logger => @logger,
                                       :region => region

        s3_uploader.upload_file :bucket          => bucket,
                                :file            => file,
                                :id              => id,
                                :key_folder      => key_folder,
                                :key_name        => key_name,
                                :name            => name,
                                :public_readable => public_readable
      end
    end

  end
end
