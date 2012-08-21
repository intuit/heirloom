module Heirloom

  class Setuper

    def initialize(args)
      @config = args[:config]
      @name   = args[:name]
      @logger = @config.logger
    end

    def setup(args)
      @regions       = args[:regions]
      @bucket_prefix = args[:bucket_prefix]
      @domain        = "heirloom_#{@name}"
      create_buckets
      create_domain
    end

    private

    def create_domain
      sdb.create_domain @domain
    end

    def create_buckets
      @regions.each do |region|
        bucket = "#{@bucket_prefix}-#{region}"
       
        unless verifier.bucket_exists? :region        => region,
                                       :bucket_prefix => @bucket_prefix
          @logger.info "Creating #{bucket} in #{region}."
          s3.put_bucket bucket, region
        end
      end
    end

    def verifier
      @verifier ||= Verifier.new :config => @config,
                                 :name   => @name
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
