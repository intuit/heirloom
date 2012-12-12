module Heirloom

  class Uploader

    def initialize(args)
      @config = args[:config]
      @name   = args[:name]
      @id     = args[:id]
      @logger = @config.logger
    end

    def upload(args)
      heirloom_file   = args[:file]
      bucket_prefix   = args[:bucket_prefix]
      regions         = args[:regions]
      public_readable = args[:public_readable]
      secret          = args[:secret]

      key_name = secret ? "#{@id}.tar.gz.gpg" : "#{@id}.tar.gz"

      regions.each do |region|
        bucket = "#{bucket_prefix}-#{region}"

        s3_uploader = Uploader::S3.new :config => @config,
                                       :logger => @logger,
                                       :region => region

        s3_uploader.upload_file :bucket          => bucket,
                                :file            => heirloom_file,
                                :id              => @id,
                                :key_folder      => @name,
                                :key_name        => key_name,
                                :name            => @name,
                                :public_readable => public_readable

        s3_uploader.add_endpoint_attributes :bucket   => bucket,
                                            :id       => @id,
                                            :name     => @name,
                                            :key_name => key_name
      end
      @logger.info "Upload complete."
    end

  end
end
