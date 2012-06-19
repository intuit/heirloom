module Heirloom

  class ArtifactReader

    def initialize(args)
      @config = args[:config]
      @name = args[:name]
      @id = args[:id]
    end

    def show
      items = sdb.select "select * from #{@name} where itemName() = '#{@id}'"
      items[@id]
    end

    def exists?
      show != nil
    end

    def get_bucket(args)
      url = show["#{args[:region]}-s3-url"].first

      bucket = url.gsub('s3://', '').split('/').first
    end

    def get_key(args)
      url = show["#{args[:region]}-s3-url"].first

      bucket = url.gsub('s3://', '').gsub(get_bucket, '')
      bucket.slice!(0)
      bucket
    end

    private

    def sdb
      @sdb ||= AWS::SimpleDB.new :config => @config
    end

  end
end
