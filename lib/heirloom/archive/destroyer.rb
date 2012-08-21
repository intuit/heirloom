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
      keep_domain = args[:keep_domain]

      @logger.info "Destroying #{@name} - #{@id}"

      regions.each do |region|
        bucket = reader.get_bucket :region => region

        key = "#{@id}.tar.gz"

        if bucket
          @logger.info "Destroying 's3://#{bucket}/#{@name}/#{key}'."

          s3_destroyer = Destroyer::S3.new :config => @config,
                                           :region => region

          s3_destroyer.destroy_file :key_name   => key,
                                    :bucket     => bucket,
                                    :key_folder => @name
        end
      end

      sdb.delete @domain, @id

      destroy_domain unless keep_domain
    end

    private

    def destroy_domain

      # Simple DB is eventually consisten
      # Sleep for 3 sec for changes to reflect
      Kernel.sleep 3

      if sdb.domain_empty? @domain
        @logger.info "Domain #{@domain} empty. Destroying."
        sdb.delete_domain @domain
      end

      @logger.info "Destroy complete."
    end

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
