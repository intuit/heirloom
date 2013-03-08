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

      @logger.info "Authorizing #{@accounts.join(', ')}."

      key_name = reader.key_name

      regions.each do |region|
        bucket = reader.get_bucket :region => region

        s3_acl = ACL::S3.new :config => @config,
                             :region => region

        s3_acl.allow_read_access_from_accounts :key_name   => key_name,
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
        @type_of_id = detect_id_type account
        case @type_of_id
          when 'email'
            @logger.info "Using email #{account} for authorization"
            return true
          when 'longid'
            @logger.info "Using longid #{account} for authorization"
            return true
          when 'shortid'
            @logger.error "#{account} passed in a short id which is not supported in AWS yet."
            return false
          else
            @logger.error "#{account} is not a valid accound type (Canonical ID, or email)."
            return false
        end
      end
    end

    def validate_email email
      email_pattern = (email =~ /^.*@.*\..*$/)
      email_pattern.nil? ? false : true
    end

    def detect_id_type account
      if validate_email account
        @logger.info "#{account} Passed an account in email format"
        return 'email'
      elsif account
        @logger.info "#{account} Passed an account in ID format"
        return 'longid' if account.length == 64
        return 'shortid' if account.length == 14
      end
    end

    def reader
      @reader ||= Reader.new :config => @config,
                             :name   => @name,
                             :id     => @id
    end

  end
end
