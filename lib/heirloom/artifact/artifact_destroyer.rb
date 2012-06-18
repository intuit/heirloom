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
        puts "#{region}, #{name}, #{id}"
        bucket = artifact_reader.get_bucket :region => region,
                                            :name   => name,
                                            :id     => id
        key = "#{id}.tar.gz"

        @logger.info "Deleting s3://#{bucket}/#{name}/#{key}"

        s3_destroyer = Destroyer::S3.new :config => @config,
                                         :region => region

        s3_destroyer.destroy_file :key_name => key,
                                  :key_folder => name,
                                  :bucket => bucket

      end
      sdb.delete name, id
    end

    private

    def sdb
      @sdb ||= AWS::SimpleDB.new :config => @config
    end

    def artifact_reader
      @artifact_reader ||= ArtifactReader.new :config => @config
    end

  end
end
