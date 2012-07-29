module Heirloom

  class Reader

    attr_accessor :config, :id, :name

    def initialize(args)
      self.config = args[:config]
      self.name = args[:name]
      self.id = args[:id]
      @logger = config.logger
    end

    def exists?
      if show.any?
        @logger.debug "Found entry for #{id} in SimpleDB."
        true
      else
        @logger.debug "Entry for #{id} not found in SimpleDB."
        false
      end
    end

    def regions
      data = show.keys.map do |key|
        key.gsub('-s3-url', '') if key =~ /-s3-url$/
      end
      data.compact
    end

    def get_bucket(args)
      @logger.debug "Looking for bucket in #{args[:region]} for #{id}"
      url = get_url(args)
      if url
        bucket = url.gsub('s3://', '').split('/').first
        @logger.debug "Found bucket #{bucket}."
        bucket
      else
        @logger.debug "Bucket not found."
        nil
      end
    end

    def get_key(args)
      url = get_url(args)
      if url
        bucket_path = get_bucket :region => args[:region]
        bucket = url.gsub('s3://', '').gsub(bucket_path, '')
        bucket.slice!(0)
        bucket
      else
        nil
      end
    end

    def show
      query = sdb.select "select * from #{name} where itemName() = '#{id}'"
      items = query[id] ? query[id] : {}
      r = {}
      items.each_pair.map do |key,value|
        r[key] = value.first
      end
      r
    end

    private

    def get_url(args)
      return nil unless exists?
      @logger.debug "Looking for #{args[:region]} endpoint for #{id}"
      url = "#{args[:region]}-s3-url"
      if show[url]
        @logger.debug "Found #{url} for #{id}."
        show[url]
      else
        @logger.debug "#{args[:region]} endpoint for #{id} not found."
        nil
      end
    end

    def sdb
      @sdb ||= AWS::SimpleDB.new :config => @config
    end

  end
end
