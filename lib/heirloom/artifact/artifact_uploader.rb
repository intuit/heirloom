module Heirloom

  class ArtifactUploader

    def initialize(args)
      @config = args[:config]
    end

    def upload(args)
      id = args[:id]
      name = args[:name]
      file = args[:file]
      public_readable = args[:public_readable]

      @config.regions.each do |region|
        bucket = "#{@config.bucket_prefix}-#{region}"

        s3_uploader = Uploader::S3.new :config => @config,
                                       :region => region,

        s3_uploader.upload_file :file => file
                                :bucket => bucket,
                                :key_name => id,
                                :key_folder => name,
                                :public_readable => public_readable
      end
    end

  end
end
