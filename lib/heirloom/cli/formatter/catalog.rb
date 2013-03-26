module Heirloom
  module CLI
    module Formatter
      class Catalog
        def format(args)
          @catalog = args[:catalog]
          @name    = args[:name]

          return summary unless @name

          return "Heirloom #{@name} not found in catalog." unless name_exists?

          filter_by_name
          details
        end

        private

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
            urls = []
            @catalog[k]["regions"].each {|region|urls.push("s3://" + @catalog[k]["bucket_prefix"].first + "-" + region + "/" + k)}

            d = k + "\n"
            d << "  Regions       : " + @catalog[k]["regions"].join(", ") + "\n"
            d << "  Bucket Prefix : " + @catalog[k]["bucket_prefix"].first + "\n"
            d << "  URLs          : " + urls.join("\n                  ")
          end
          data.join "\n"
        end
      end
    end
  end
end
