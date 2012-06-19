module Heirloom

  class ArtifactLister

    def initialize(args)
      @config = args[:config]
      @name = args[:name]
    end

    def list
      sdb.select("select * from #{@name}").keys.reverse
    end

    private

    def sdb
      @sdb ||= AWS::SimpleDB.new :config => @config
    end

    def artifact_reader(id)
      @artifact_reader ||= ArtifactReader.new :config => @config,
                                              :name   => @name,
                                              :id     => id
    end

  end
end
