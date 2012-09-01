module Heirloom
  class Catalog
    class Show

      def initialize(args)
        @config = args[:config]
        @name   = args[:name]
      end

      def regions
        query = "select regions from heirloom where itemName() = 'heirloom_#{@name}'"
        sdb.select(query)["heirloom_#{@name}"]["regions"]
      end

      def base
        query = "select base from heirloom where itemName() = 'heirloom_#{@name}'"
        sdb.select(query)["heirloom_#{@name}"]["base"].first
      end

      private

      def sdb
        @sdb ||= AWS::SimpleDB.new :config => @config
      end

    end
  end
end
