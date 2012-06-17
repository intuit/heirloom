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

    private

    def sdb
      @sdb ||= AWS::SimpleDB.new :config => @config
    end

  end
end
