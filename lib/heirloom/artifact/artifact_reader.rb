module Heirloom

  class ArtifactReader

    def initialize(args)
      @config = Config.new
    end

    def show(args)
      domain = args[:name]
      version = args[:version]
      sdb.select "select * from #{domain} where itemName() = '#{version}'"
    end

    private

    def sdb
      @sdb ||= AWS::SimpleDB.new :config => @config
    end

  end
end
