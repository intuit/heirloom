module Heirloom

  class ArtifactAuthorizer

    def initialize(args)
      @config = args[:config]
      @name   = args[:name]
      @id     = args[:id]
      @logger = @config.logger
    end

    def authorize
      @logger.info "Authorizing access to artifact."

      @config.regions.each do |region|
        bucket = artifact_reader.get_bucket :region => region

        s3_acl = ACL::S3.new :config => @config,
                             :logger => @logger,
                             :region => region

        s3_acl.allow_read_access_from_accounts :key_name => @id,
                                               :key_folder => @name,
                                               :bucket => bucket
      end

      @logger.info "Authorization complete."
    end

    private

    def artifact_reader
      @artifact_reader ||= ArtifactReader.new :config => @config,
                                              :name   => @name,
                                              :id     => @id
    end

  end
end
