module Heirloom

  class Authorizer
    
    include Heirloom::Utils::Email

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
      status = true

      @accounts.each do |account|
        case account_type(account)
          when 'email'
            @logger.info "Using email #{account} for authorization"
          when 'canonical_id'
            @logger.info "Using canonical_id #{account} for authorization"
          when 'short_id'
            @logger.error "#{account} passed in a short id which is not supported in AWS yet."
            status = false
          else
            @logger.error "#{account} is not a valid accound type (Canonical ID, or email)."
            status = false
        end
      end

      status
    end

    def account_type account
      if valid_email? account
        return 'email'
      elsif account.length == 64
        return 'canonical_id' 
      elsif account.length == 14
        return 'short_id'
      else
        @logger.info "#{account} account type not detected"
      end
    end

    def reader
      @reader ||= Reader.new :config => @config,
                             :name   => @name,
                             :id     => @id
    end

  end
end
