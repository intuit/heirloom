module Heirloom

  class ArtifactDestroyer

    def initialize(args)
      @config = args[:config]
      @logger = args[:logger]
    end

    def destroy(args)
      id = args[:id]
      name = args[:name]

      @logger.info "Destroying #{args[:name]} - #{args[:id]}"

      @config.regions.each do |region|
        bucket = "#{@config.bucket_prefix}-#{region}"
        key = "#{id}.tar.gz"

        @logger.info "Deleting s3://#{bucket}/#{name}/#{key}"

        s3_destroyer = Destroyer::S3.new :config => @config,
                                         :region => region

        s3_destroyer.destroy_file :key_name => key,
                                  :key_folder => name,
                                  :bucket => bucket

        sdb.delete name, id
      end
    end

    private

    def sdb
      @sdb ||= AWS::SimpleDB.new :config => @config
    end

  end
end
