module Heirloom

  class Authorizer

    def initialize(args)
      @config = args[:config]
      @name   = args[:name]
      @id     = args[:id]
      @logger = @config.logger
    end

    def authorize(args)
      regions = args[:regions]
      accounts = args[:accounts]

      @logger.info "Authorizing access to artifact."

      regions.each do |region|
        bucket = reader.get_bucket :region => region

        s3_acl = ACL::S3.new :config => @config,
                             :region => region

        s3_acl.allow_read_access_from_accounts :key_name   => @id,
                                               :key_folder => @name,
                                               :bucket     => bucket,
                                               :accounts   => accounts
      end

      @logger.info "Authorization complete."
    end

    private

    def reader
      @reader ||= Reader.new :config => @config,
                             :name   => @name,
                             :id     => @id
    end

  end
end
