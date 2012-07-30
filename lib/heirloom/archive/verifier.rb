module Heirloom

  class Verifier

    def initialize(args)
      @config = args[:config]
      @name = args[:name]
      @logger = @config.logger
    end

    def buckets_exist?(args)
      bucket_prefix = args[:bucket_prefix]
      regions = args[:regions]
      result = true

      regions.each do |region|
        bucket = "#{bucket_prefix}-#{region}"
        
        s3 ||= AWS::S3.new :config => @config,
                           :region => region

        if s3.get_bucket bucket
          @logger.debug "#{bucket} exists in #{region}"
        else
          @logger.debug "#{bucket} in #{region} does not exist"
          result = false
        end

      end

      result
    end

  end
end
