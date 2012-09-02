module Heirloom
  class Catalog
    class Add

      def initialize(args)
        @config  = args[:config]
        @name    = args[:name]
        @logger  = @config.logger
      end

      def add_to_catalog(args)
        regions = args[:regions]
        base    = args[:base]

        return false if entry_exists_in_catalog?

        @logger.info "Adding #{@name} to catalog."

        sdb.put_attributes 'heirloom', 
                           "heirloom_#{@name}", 
                           { "regions" => regions, "base" => base }

      end

      def entry_exists_in_catalog?
        verify.entry_exists_in_catalog? @name
      end

      private

      def sdb
        @sdb ||= AWS::SimpleDB.new :config => @config
      end

      def verify
        @verify ||= Catalog::Verify.new :config => @config
      end

    end
  end
end
