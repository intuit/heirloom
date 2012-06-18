module Heirloom

  class ArtifactAuthorizer

    def initialize(args)
      @config = args[:config]
      @logger = args[:logger]
    end

    def authorize(args)
      id = args[:id]
      name = args[:name]
      public_readable = args[:public_readable]

      unless public_readable
        @logger.info "Authorizing access to artifact."

        @config.regions.each do |region|
          bucket = artifact_reader.get_bucket :region => region,
                                              :name   => name,
                                              :id     => id
          s3_acl = ACL::S3.new :config => @config,
                               :logger => @logger,
                               :region => region

          s3_acl.allow_read_acccess_from_accounts :key_name => id,
                                                  :key_folder => name,
                                                  :bucket => bucket
        end
      end
    end

    private

    def artifact_reader
      @artifact_reader ||= ArtifactReader.new :config => @config
    end

  end
end
