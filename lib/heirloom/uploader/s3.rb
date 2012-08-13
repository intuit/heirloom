module Heirloom
  class Uploader
    class S3

      def initialize(args)
        @config = args[:config]
        @region = args[:region]
        @logger = args[:logger]
      end

      def upload_file(args)
        bucket = args[:bucket]
        file = args[:file]
        id = args[:id]
        key_name = args[:key_name]
        key_folder = args[:key_folder]
        name = args[:name]
        public_readable = args[:public_readable]

        s3_bucket = s3.get_bucket bucket

        @logger.info "Uploading s3://#{bucket}/#{key_folder}/#{key_name}"

        s3_bucket.files.create :key    => "#{key_folder}/#{key_name}",
                               :body   => File.open(file),
                               :public => public_readable

        @logger.info "File is readable by the public internet." if public_readable
      end

      def add_endpoint_attributes(args)
        bucket = args[:bucket]
        id = args[:id]
        name = args[:name]
        domain = "heirloom_#{name}"
        key_folder = name
        key_name = "#{id}.tar.gz"

        s3_endpoint = "s3://#{bucket}/#{key_folder}/#{key_name}"
        http_endpoint = "http://#{endpoints[@region]}/#{bucket}/#{key_folder}/#{key_name}"
        https_endpoint = "https://#{endpoints[@region]}/#{bucket}/#{key_folder}/#{key_name}"

        sdb.put_attributes domain, id, { "#{@region}-s3-url" => s3_endpoint }
        @logger.info "Adding attribute #{s3_endpoint}."

        sdb.put_attributes domain, id, { "#{@region}-http-url" => http_endpoint }
        @logger.info "Adding attribute #{http_endpoint}."

        sdb.put_attributes domain, id, { "#{@region}-https-url" => https_endpoint }
        @logger.info "Adding attribute #{https_endpoint}."
      end

      private

      def endpoints
        {
          'us-east-1' => 's3.amazonaws.com',
          'us-west-1' => 's3-us-west-1.amazonaws.com',
          'us-west-2' => 's3-us-west-2.amazonaws.com'
        }
      end

      def s3
        @s3 ||= AWS::S3.new :config => @config,
                            :region => @region
      end

      def sdb
        @sdb ||= AWS::SimpleDB.new :config => @config
      end

    end
  end
end
