module Heirloom
  class Catalog
    class Show

      def initialize(args)
        @config = args[:config]
        @name   = args[:name]
      end

      def regions
        lookup :name => @name, :attribute => 'regions'
      end

      def base
        lookup(:name => @name, :attribute => 'base').first
      end

      private

      def lookup(args)
        name      = args[:name]
        attribute = args[:attribute]
        domain    = "heirloom_#{name}"
        query     = "select #{attribute} from heirloom where itemName() = '#{domain}'"
        result    = sdb.select(query)
        result[domain][attribute]
      end

      def sdb
        @sdb ||= AWS::SimpleDB.new :config => @config
      end

    end
  end
end
