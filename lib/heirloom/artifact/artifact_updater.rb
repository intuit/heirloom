module Heirloom

  class ArtifactUpdater

    def initialize(args)
      @config = args[:config]
      @logger = args[:logger]
      @name = args[:name]
      @id = args[:id]
    end

    def update(args)
      attribute = args[:attribute]
      update = args[:update]

      sdb.put_attributes @name, @id, { attribute => update }, { :replace => attribute }
      @logger.info "Updated #{@name} (#{@id}): #{attribute} = #{update}."
    end

    private

    def sdb
      @sdb ||= AWS::SimpleDB.new :config => @config
    end

  end
end
