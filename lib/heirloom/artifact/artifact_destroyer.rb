module Heirloom

  class ArtifactDestroyer

    def initialize(args)
      @config = args[:config]
      @logger = args[:logger]
      @name = args[:name]
      @id = args[:id]
    end

    def destroy
      @logger.info "Destroying #{@name} - #{@id}"

      @config.regions.each do |region|
        bucket = artifact_reader.get_bucket :region => region

        key = "#{@id}.tar.gz"

        @logger.info "Deleting s3://#{bucket}/#{@name}/#{key}"

        s3_destroyer = Destroyer::S3.new :config => @config,
                                         :region => region

        s3_destroyer.destroy_file :key_name => key,
                                  :key_folder => @name,
                                  :bucket => bucket

      end
      sdb.delete @name, @id
      @logger.info "Destroy complete."
    end

    private

    def sdb
      @sdb ||= AWS::SimpleDB.new :config => @config
    end

    def artifact_reader
      @artifact_reader ||= ArtifactReader.new :config => @config,
                                              :name   => @name,
                                              :id     => @id
    end

  end
end
