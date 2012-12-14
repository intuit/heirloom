module Heirloom

  class Destroyer

    def initialize(args)
      @config = args[:config]
      @name = args[:name]
      @domain = "heirloom_#{@name}"
      @id = args[:id]
      @logger = @config.logger
    end

    def destroy(args)
      regions = args[:regions]

      @logger.info "Destroying #{@name} #{@id}"

      regions.each do |region|
        bucket = reader.get_bucket :region => region

        key_name = reader.key_name

        if bucket
          @logger.debug "Destroying 's3://#{bucket}/#{@name}/#{key_name}'."

          s3_destroyer = Destroyer::S3.new :config => @config,
                                           :region => region

          s3_destroyer.destroy_file :key_name   => key_name,
                                    :bucket     => bucket,
                                    :key_folder => @name
        end
      end

      sdb.delete @domain, @id
    end

    private

    def sdb
      @sdb ||= AWS::SimpleDB.new :config => @config
    end

    def reader
      @reader ||= Reader.new :config => @config,
                             :name   => @name,
                             :id     => @id
    end

  end
end
