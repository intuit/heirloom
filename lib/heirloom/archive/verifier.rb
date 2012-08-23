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
        unless bucket_exists? :region        => region,
                              :bucket_prefix => bucket_prefix
          result = false
        end
      end

      result
    end

    def bucket_exists?(args)
      bucket_prefix = args[:bucket_prefix]
      region = args[:region]

      bucket = "#{bucket_prefix}-#{region}"
      
      s3 ||= AWS::S3.new :config => @config,
                         :region => region

      if s3.get_bucket bucket
        @logger.debug "Bucket '#{bucket}' exists in '#{region}'."
        true
      else
        @logger.info "Bucket '#{bucket}' does not exist in '#{region}'."
        false
      end
    end

    def domain_exists?
      domain = "heirloom_#{@name}"
      region = @config.metadata_region
      if sdb.domain_exists? domain
        @logger.debug "Domain '#{@name}' exists in '#{region}'."
        true
      else
        @logger.info "Domain '#{@name}' does not exist in '#{region}'."
        false
      end
    end

    private

    def sdb
      @sdb ||= AWS::SimpleDB.new :config => @config
    end

  end
end
