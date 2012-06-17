module Heirloom

  class ArtifactBuilder

    def initialize(args)
      @config = args[:config]
      @logger = args[:logger]
    end

    def update(args)
      attribute = args[:attribute]
      id = args[:id]
      name = args[:name]
      update = args[:update]

      sdb.put_attributes name, id, { attribute => update }
      @logger.info "Updated #{name} (#{id}): #{attribute} = #{update}"
    end

    private

    def sdb
      @sdb ||= AWS::SimpleDB.new :config => @config
    end

  end
end
