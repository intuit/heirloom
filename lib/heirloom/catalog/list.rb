module Heirloom
  class Catalog
    class List

      def initialize(args)
        @config = args[:config]
      end

      def all
        query  = "SELECT * FROM heirloom"
        sdb.select query
      end

      private

      def sdb
        @sdb ||= AWS::SimpleDB.new :config => @config
      end

    end
  end
end
