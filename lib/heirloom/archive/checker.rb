module Heirloom

  class Checker

    def initialize(args)
      @config = args[:config]
      @logger = @config.logger
    end

    def bucket_name_available?(args)
      bucket_prefix = args[:bucket_prefix]
      regions       = args[:regions]
      result        = true

      regions.each do |region|
        s3 = AWS::S3.new :config => @config,
                         :region => region
        bucket = "#{bucket_prefix}-#{region}"

        unless s3.bucket_name_available_in_region? bucket
          @logger.debug "Bucket '#{bucket}' unavailable in '#{region}'."
          result = false
        end
      end

      result
    end

  end
end
