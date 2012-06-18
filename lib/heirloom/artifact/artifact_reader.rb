module Heirloom

  class ArtifactReader

    def initialize(args)
      @config = args[:config]
    end

    def show(args)
      domain = args[:name]
      id = args[:id]
      items = sdb.select "select * from #{domain} where itemName() = '#{id}'"
      items[id]
    end

    def exists?(args)
      show(args) != nil
    end

    def get_bucket(args)
      artifact = show :name => args[:name],
                      :id   => args[:id]

      url = artifact["#{args[:region]}-s3-url"].first

      bucket = url.gsub('s3://', '').split('/').first
    end

    def get_key(args)
      artifact = show :name => args[:name],
                      :id   => args[:id]

      url = artifact["#{args[:region]}-s3-url"].first

      bucket = url.gsub('s3://', '').gsub(get_bucket(args), '')
      bucket.slice!(0)
      bucket
    end

    private

    def sdb
      @sdb ||= AWS::SimpleDB.new :config => @config
    end

  end
end
