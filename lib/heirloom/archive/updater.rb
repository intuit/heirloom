module Heirloom

  class Updater

    def initialize(args)
      @config = args[:config]
      @name = args[:name]
      @id = args[:id]

      @logger = @config.logger
    end

    def update(args)
      attribute = args[:attribute]
      value = args[:value]

      sdb.put_attributes @name, @id, { attribute => value }, { :replace => attribute }
      @logger.info "Updated #{@name} (#{@id}): #{attribute} = #{value}."
    end

    private

    def sdb
      @sdb ||= AWS::SimpleDB.new :config => @config
    end

  end
end
