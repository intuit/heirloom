module Heirloom

  class Reader

    attr_accessor :config, :id, :name

    def initialize(args)
      self.config = args[:config]
      self.name = args[:name]
      self.id = args[:id]
      @logger = config.logger
    end

    def show
      items = sdb.select "select * from #{name} where itemName() = '#{id}'"
      items[id]
    end

    def exists?
      show ? true : false
    end

    def get_bucket(args)
      url = get_url(args)
      @logger.debug "Looking for bucket in #{args[:region]} for #{id}"
      if url
        bucket = get_url(args).gsub('s3://', '').split('/').first
        @logger.debug "Found bucket #{bucket}."
        bucket
      else
        nil
      end
    end

    def get_key(args)
      bucket_path = get_bucket :region => args[:region]
      bucket = get_url(args).gsub('s3://', '').gsub(bucket_path, '')
      bucket.slice!(0)
      bucket
    end

    def get_url(args)
      url = "#{args[:region]}-s3-url"
      @logger.debug "Looking for #{args[:region]} endpoint for #{id}"
      if show && show[url]
        @logger.debug "Found #{url} for #{id}."
        show[url].first
      else
        @logger.debug "#{args[:region]} endpoint for #{id} not found."
        nil
      end
    end

    private

    def sdb
      @sdb ||= AWS::SimpleDB.new :config => @config
    end

  end
end
