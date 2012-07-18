module Heirloom

  class Lister

    def initialize(args)
      @config = args[:config]
      @name = args[:name]
    end

    def list(limit=10)
      sdb.select("select * from #{@name} where built_at > '2000-01-01T00:00:00.000Z'\
                  order by built_at desc limit #{limit}").keys
    end

    private

    def sdb
      @sdb ||= AWS::SimpleDB.new :config => @config
    end

  end
end
