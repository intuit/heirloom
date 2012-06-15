require 'fog'

module Heirloom
  module AWS
    class S3

      def initialize(args)
        @config = args[:config]
        @region = args[:region]

        @s3 = Fog::Storage.new :provider                 => 'AWS',
                               :aws_access_key_id        => @config.access_key,
                               :aws_secret_access_key    => @config.secret_key,
                               :region                   => @region
      end

      def delete_object(bucket_name, object_name, options = {})
        @s3.delete_object(bucket_name, object_name, options = {})
      end

      def get_bucket(bucket)
        @s3.directories.get bucket
      end

      def get_bucket_acl(bucket)
        @s3.get_bucket_acl(bucket).body
      end

      def put_object_acl(bucket, key, grants)
        @s3.put_object_acl(bucket, key, grants)
      end

    end
  end
end
