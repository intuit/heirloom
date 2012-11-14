require 'fog'

module Heirloom
  module AWS
    class S3

      def initialize(args)
        @config = args[:config]
        @region = args[:region]
        @logger = @config.logger

        @s3 = Fog::Storage.new :provider              => 'AWS',
                               :aws_access_key_id     => @config.access_key,
                               :aws_secret_access_key => @config.secret_key,
                               :region                => @region
      end

      def delete_object(bucket_name, object_name, options = {})
        @s3.delete_object(bucket_name, object_name, options)
      end

      def get_bucket(bucket)
        @s3.directories.get bucket
      end

      def bucket_name_available_in_region?(bucket)

        @logger.info "Checking for #{bucket} availability in #{@region}."

        begin
          bucket_object = get_bucket bucket
        rescue Excon::Errors::Forbidden
          @logger.warn "#{bucket} owned by another account."
          return false
        end

        if bucket_object.nil?
          @logger.debug "#{bucket} available."
          return true
        end

        if bucket_object.location != @region
          @logger.warn "#{bucket} already exists in another region."
          return false
        end

        true
      end

      def delete_bucket(bucket)
        @s3.delete_bucket bucket
      end

      def get_object(bucket_name, object_name)
        @s3.get_object(bucket_name, object_name).body
      end

      def get_bucket_acl(bucket)
        @s3.get_bucket_acl(bucket).body
      end

      def put_object_acl(bucket, key, grants)
        @s3.put_object_acl(bucket, key, grants)
      end

      def put_bucket(bucket_name, region)
        region = nil if region == 'us-east-1'
        options = { 'LocationConstraint' => region,
                    'x-amz-acl'          => 'private' }
        @s3.put_bucket bucket_name, options
      end

    end
  end
end
