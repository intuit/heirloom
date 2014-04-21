module Heirloom
  class Catalog
    class Verify

      def initialize(args)
        @config = args[:config]
        @logger = @config.logger
        @region = @config.metadata_region
      end

      def catalog_domain_exists?
        if sdb.domain_exists? 'heirloom'
          @logger.debug "Catalog of Heirlooms exists in #{@region}."
          true
        else
          @logger.debug "Catalog of Heirlooms does not exist in #{@region}."
          false
        end
      end

      def entry_exists_in_catalog?(entry)
        if sdb.item_count('heirloom', "heirloom_#{entry}").zero?
          @logger.debug "#{entry} does not exist in catalog in #{@region}."
          false
        else
          @logger.debug "#{entry} exists in catalog in #{@region}."
          true
        end
      end

      private

      def sdb
        @sdb ||= AWS::SimpleDB.new :config => @config
      end

    end
  end
end
