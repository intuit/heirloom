module Heirloom

  class ArtifactReader

    def initialize(args)
      @config = Config.new
    end

    def show(args)
      domain = args[:name]
      id = args[:id]
      sdb.select "select * from #{domain} where itemName() = '#{id}'"
    end

    def exists?(args)
      show(args).any?
    end

    private

    def sdb
      @sdb ||= AWS::SimpleDB.new :config => @config
    end

  end
end
