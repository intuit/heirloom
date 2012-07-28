module Heirloom

  class Destroyer

    attr_accessor :config, :id, :logger, :name

    def initialize(args)
      self.config = args[:config]
      self.name = args[:name]
      self.id = args[:id]
      self.logger = config.logger
    end

    def destroy
      regions = args[:regions]

      logger.info "Destroying #{@name} - #{@id}"

      regions.each do |region|
        bucket = reader.get_bucket :region => region

        key = "#{id}.tar.gz"

        if bucket
          logger.info "Destroying 's3://#{bucket}/#{name}/#{key}'."

          s3_destroyer = Destroyer::S3.new :config => config,
                                           :region => region

          s3_destroyer.destroy_file :key_name => key,
                                    :key_folder => name,
                                    :bucket => bucket
        end
      end
      sdb.delete name, id
      logger.info "Destroy complete."
    end

    private

    def sdb
      @sdb ||= AWS::SimpleDB.new :config => @config
    end

    def reader
      @reader ||= Reader.new :config => config,
                             :name   => name,
                             :id     => id
    end

  end
end
