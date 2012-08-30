module Heirloom
  class Catalog
    class Lister

      def initialize(args)
        @config = args[:config]
      end

      def list
        sdb.select("select * from heirloom").keys
      end

      private

      def sdb
        @sdb ||= AWS::SimpleDB.new :config => @config
      end

    end
  end
end
