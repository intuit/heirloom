module Heirloom
  module CLI
    module Formatter
      class Catalog
        def format(args)
          @catalog = args[:catalog]
          @name    = args[:name]
          @region  = args[:region]
          @json    = args[:json]

          @catalog = catalog_format

          return @region, summary unless @name

          #return "Heirloom #{@name} not found in catalog for #{@region}." unless name_exists?
          return false unless name_exists?
            filter_by_name
            details
        end

        private

        def catalog_format
          indent = ''
          indent = '  ' unless @json || @name
          Hash[@catalog.sort.map { |k, v| [k.sub(/heirloom_/, indent), v] }]
        end

        def name_exists?
          @catalog.include? @name
        end

        def filter_by_name
          @catalog.select! {|k| @name == k }
        end

        def summary
          @catalog.keys.join "\n"
        end

        def details
          data = @catalog.each_pair.map do |k,v|
            urls = v["regions"].map do |region|
              bucket_prefix = v["bucket_prefix"].first
              "  #{region}-s3-url : s3://#{bucket_prefix}-#{region}/#{k}"
            end

            d = k + "\n"
            d << "  metadata_region  : #{@region}\n"
            d << "  regions          : " + @catalog[k]["regions"].join(", ") + "\n"
            d << "  bucket_prefix    : " + @catalog[k]["bucket_prefix"].first + "\n"
            d << urls.join("\n")
          end
          data.join "\n"
        end
      end
    end
  end
end
