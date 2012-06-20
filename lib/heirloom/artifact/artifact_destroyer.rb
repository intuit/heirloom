module Heirloom

  class ArtifactDestroyer

    attr_accessor :config, :id, :logger, :name

    def initialize(args)
      self.config = args[:config]
      self.name = args[:name]
      self.id = args[:id]
      self.logger = config.logger
    end

    def destroy
      logger.info "Destroying #{@name} - #{@id}"

      config.regions.each do |region|
        bucket = artifact_reader.get_bucket :region => region

        key = "#{id}.tar.gz"

        logger.info "Destroying 's3://#{bucket}/#{name}/#{key}'."

        s3_destroyer = Destroyer::S3.new :config => config,
                                         :region => region

        s3_destroyer.destroy_file :key_name => key,
                                  :key_folder => name,
                                  :bucket => bucket

      end
      sdb.delete name, id
      logger.info "Destroy complete."
    end

    private

    def sdb
      @sdb ||= AWS::SimpleDB.new :config => @config
    end

    def artifact_reader
      @artifact_reader ||= ArtifactReader.new :config => config,
                                              :name   => name,
                                              :id     => id
    end

  end
end
