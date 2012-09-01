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
          @logger.debug "Catalog exists in #{@region}."
          true
        else
          @logger.debug "Catalog does not exist in #{@region}."
          false
        end
      end

      def entry_exists_in_catalog?(entry)
        query = "select count(*) from heirloom where itemName() = 'heirloom_#{entry}'"
        count = sdb.select(query)['Domain']['Count'].first.to_i

        if count.zero?
          @logger.debug "#{entry} does not exist in catalog."
          false
        else
          @logger.debug "#{entry} exists in catalog."
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
