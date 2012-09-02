module Heirloom

  class Teardowner

    def initialize(args)
      @config = args[:config]
      @name   = args[:name]
      @domain = "heirloom_#{@name}"
      @logger = @config.logger
    end

    def setup(args)
      @regions       = args[:regions]
      @bucket_prefix = args[:bucket_prefix]
      delete_buckets
      remove_domain
      @logger.info "Teardown complete."
    end

    private

    def create_buckets
      @regions.each do |region|
        bucket = "#{@bucket_prefix}-#{region}"
       
        unless verifier.bucket_exists? :region        => region,
                                       :bucket_prefix => @bucket_prefix
          @logger.info "Creating bucket #{bucket} in #{region}."
          s3 = AWS::S3.new :config => @config,
                           :region => region
          s3.put_bucket bucket, region
        end
      end
    end

    def create_domain
      region = @config.metadata_region

      unless verifier.domain_exists?
        @logger.info "Creating domain #{@name} in #{region}."
        sdb.create_domain @domain 
      end
    end

    def verifier
      @verifier ||= Verifier.new :config => @config,
                                 :name   => @name
    end

    def sdb
      @sdb ||= AWS::SimpleDB.new :config => @config
    end
  end
end
