module Heirloom
  module Uploader
    class S3

    def initialize(args)
      @config = args[:config]
      @region = args[:region]
      @bucket = "#{@config.bucket_prefix}-#{region}"
    end

    def upload_file(args)
      file = args[:file]
      key_name = args[:key_name]
      key_folder = args[:key_folder]
      public_readable = args[:public]

      b = s3.directories.get @bucket
      b.files.create :key    => "#{key_folder}/#{key_name}",
                     :body   => File.open file,
                     :public => public_readable
    end

    private

    def s3
      @s3 ||= AWS::S3.new :config => @config,
                          :region => @region
    end

  end
end
