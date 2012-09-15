module Heirloom
  module CLI
    module Formatter
      class Catalog
        def format(args)
          @catalog = args[:catalog]
          @details = args[:details]
          @name    = args[:name]

          filter if @name

          @details ? details : summary
        end

        private

        def filter
          @catalog.select! {|k| @name == k }
        end

        def summary
          @catalog.keys.join("\n")
        end

        def details
          data = @catalog.each_pair.map do |k,v|
            d = k + "\n"
            d << "  Regions       : " + @catalog[k]["regions"].join(", ") + "\n"
            d << "  Bucket Prefix : " + @catalog[k]["bucket_prefix"].first
          end
          data.join "\n"
        end
      end
    end
  end
end
