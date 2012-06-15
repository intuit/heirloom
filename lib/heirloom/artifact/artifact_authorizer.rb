require 'socket'
require 'time'

module Heirloom

  class ArtifactAuthorizer

    def initialize(args)
      @config = args[:config]
    end

    def authorize(args)
      id = args[:id]
      name = args[:name]
      public_readable = args[:public_readable]

      unless @public_readable
        @config.regions.each do |region|
          bucket = "#{@config.bucket_prefix}-#{region}"

          s3_acl = ACL::S3.new :config => @config,
                               :region => region

          s3_acl.allow_read_acccess_from_accounts :key_name => id,
                                                  :key_folder => name,
                                                  :bucket => bucket
        end
      end
    end

  end
end
