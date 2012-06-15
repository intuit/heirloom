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
                                       :region => region

        s3_uploader.upload_file :file => file,
                                :bucket => bucket,
                                :key_name => "#{id}.tar.gz",
                                :key_folder => name,
                                :public_readable => public_readable
        sdb.put_attributes name, id, { "#{region}-s3-url" => 
                                       "s3://#{bucket}/#{name}/#{id}.tar.gz" }
        sdb.put_attributes name, id, { "#{region}-http-url" => 
                                       "http://#{s3_endpoints[region]}/#{bucket}/#{name}/#{id}.tar.gz" }
        sdb.put_attributes name, id, { "#{region}-https-url" => 
                                       "https://#{s3_endpoints[region]}/#{bucket}/#{name}/#{id}.tar.gz" }
      end
    end

    private

    def s3_endpoints
      {
        'us-east-1' => 's3.amazonaws.com',
        'us-west-1' => 's3-us-west-1.amazonaws.com',
        'us-west-2' => 's3-us-west-2.amazonaws.com'
      }
    end

    def sdb
      @sdb ||= AWS::SimpleDB.new :config => @config
    end

  end
end
