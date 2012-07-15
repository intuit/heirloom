module Heirloom

  class Reader

    attr_accessor :config, :id, :name

    def initialize(args)
      self.config = args[:config]
      self.name = args[:name]
      self.id = args[:id]
    end

    def show
      items = sdb.select "select * from #{name} where itemName() = '#{id}'"
      items[@id]
    end

    def exists?
      show != nil
    end

    def get_bucket(args)
      get_url(args).gsub('s3://', '').split('/').first
    end

    def get_key(args)
      bucket_path = get_bucket :region => args[:region]
      bucket = get_url(args).gsub('s3://', '').gsub(bucket_path, '')
      bucket.slice!(0)
      bucket
    end

    def get_url(args)
      show["#{args[:region]}-s3-url"].first
    end

    private

    def sdb
      @sdb ||= AWS::SimpleDB.new :config => @config
    end

  end
end
