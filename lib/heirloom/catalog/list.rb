module Heirloom
  class Catalog
    class List

      def initialize(args)
        @config = args[:config]
      end

      def list
        query  = "select * from heirloom"
        sdb.select(query).keys
      end

      private

      def sdb
        @sdb ||= AWS::SimpleDB.new :config => @config
      end

    end
  end
end
