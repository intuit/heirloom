module Heirloom

  class ArtifactDestroyer

    def initialize(args)
      @config = args[:config]
    end

    def destroy(args)
      id = args[:id]
      name = args[:name]

      @config.regions.each do |region|
        bucket = "#{@config.bucket_prefix}-#{region}"
        s3_destroyer = Destroyer::S3.new :config => @config,
                                         :region => region

        s3_destroyer.destroy_file :key_name => "#{id}.tar.gz",
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
