module Heirloom

  class Teardowner

    def initialize(args)
      @config = args[:config]
      @name   = args[:name]
      @domain = "heirloom_#{@name}"
      @logger = @config.logger
      @region = @config.metadata_region
    end

    def delete_buckets(args)
      regions       = args[:regions]
      bucket_prefix = args[:bucket_prefix]

      regions.each do |region|
        bucket = "#{bucket_prefix}-#{region}"

        if verifier.bucket_exists? :region        => region,
                                   :bucket_prefix => bucket_prefix
          @logger.info "Destroying bucket #{bucket} in #{region}."
          s3 = AWS::S3.new :config => @config,
                           :region => region
          s3.delete_bucket bucket
        end
      end
    end

    def delete_domain
      if verifier.domain_exists?
        @logger.info "Destroying domain #{@name} in #{@region}."
        sdb.delete_domain @domain 
      end
    end

    private

    def verifier
      @verifier ||= Verifier.new :config => @config,
                                 :name   => @name
    end

    def sdb
      @sdb ||= AWS::SimpleDB.new :config => @config
    end
  end
end
