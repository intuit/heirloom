module Heirloom

  class Authorizer

    def initialize(args)
      @config = args[:config]
      @name   = args[:name]
      @id     = args[:id]
      @logger = @config.logger
    end

    def authorize(args)
      @accounts = args[:accounts]
      regions = args[:regions]

      return false unless validate_format_of_accounts

      @logger.info "Authorizing access to artifact."

      regions.each do |region|
        bucket = reader.get_bucket :region => region

        s3_acl = ACL::S3.new :config => @config,
                             :region => region

        s3_acl.allow_read_access_from_accounts :key_name   => @id,
                                               :key_folder => @name,
                                               :accounts   => @accounts,
                                               :bucket     => bucket
      end

      @logger.info "Authorization complete."
      true
    end

    private

    def validate_format_of_accounts
      @accounts.each do |account|
        unless validate_email account
          @logger.error "#{account} is not a valid email address."
          return false
        end
      end
    end

    def validate_email email
      email_pattern = (email =~ /^.*@.*\..*$/)
      email_pattern.nil? ? false : true
    end

    def reader
      @reader ||= Reader.new :config => @config,
                             :name   => @name,
                             :id     => @id
    end

  end
end
