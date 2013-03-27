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

    def get_object_acl(args)
      bucket = args[:bucket]
      region = args[:region]
      object_name = "#{@name}/#{args[:object_name]}"

      s3_acl = ACL::S3.new :config => @config,
                           :region => region

      object_acl = s3_acl.get_object_acl :bucket => bucket,
                                         :object_name => object_name

      object_acl
    end

    private

    def validate_format_of_accounts
      status = true

      @accounts.each do |account|
        if valid_account?(account)
          @logger.info "Using #{account} for authorization"
        else 
          @logger.error "#{account} is not a valid account type"
          status = false
        end
      end

      status
    end

    def valid_account?(account)
      valid_email?(account) || account.length == 64
    end

    def reader
      @reader ||= Reader.new :config => @config,
                             :name   => @name,
                             :id     => @id
    end

  end
end
