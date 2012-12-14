module Heirloom
  class Uploader
    class S3

      def initialize(args)
        @config = args[:config]
        @region = args[:region]
        @logger = args[:logger]
      end

      def upload_file(args)
        bucket          = args[:bucket]
        file            = args[:file]
        id              = args[:id]
        key_name        = args[:key_name]
        key_folder      = args[:key_folder]
        name            = args[:name]
        public_readable = args[:public_readable]

        body      = File.open file
        s3_bucket = s3.get_bucket bucket

        @logger.info "Uploading s3://#{bucket}/#{key_folder}/#{key_name}"

        s3_bucket.files.create :key    => "#{key_folder}/#{key_name}",
                               :body   => body,
                               :public => public_readable
        @logger.warn "File is readable by entire Internet." if public_readable

        body.close
      end

      def add_endpoint_attributes(args)
        bucket     = args[:bucket]
        id         = args[:id]
        name       = args[:name]
        key_name   = args[:key_name]

        domain     = "heirloom_#{name}"
        key_folder = name
        endpoint   = endpoints[@region]

        path = "#{bucket}/#{key_folder}/#{key_name}"

        end_point_attributes(path).each_pair do |key, value|
          add_endpoint_attribute domain, id, key, value
        end
      end

      private

      def end_point_attributes(path)
        {
          "#{@region}-s3-url"    => "s3://#{path}",
          "#{@region}-http-url"  => "http://#{endpoints[@region]}/#{path}",
          "#{@region}-https-url" => "https://#{endpoints[@region]}/#{path}"
        }
      end

      def add_endpoint_attribute(domain, id, key, value)
        sdb.put_attributes domain, id, { key => value }
        @logger.debug "Adding tag #{key}."
        @logger.debug "Adding tag #{value}."
      end

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
