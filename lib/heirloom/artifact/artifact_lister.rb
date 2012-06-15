module Heirloom

  class ArtifactLister

    def self.list
      sdb = self.connect_to_sdb

      r = {}

      sdb.domains.each do |domain|
        r[domain] = sdb.select("select * from #{domain}")
      end

      r
    end

    def initialize(args)
      @config = Config.new
      @sdb_connect = AWS::SimpleDB.new :config => args[:config]
    end

    def list(args)
      domain = args[:name]
      @sdb_connect.select "select * from #{domain}"
    end

  end
end
