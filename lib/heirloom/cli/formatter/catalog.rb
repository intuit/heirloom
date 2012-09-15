module Heirloom
  module CLI
    module Formatter
      class Catalog
        def format(args)
          @catalog = args[:catalog]
          @details = args[:details]
          @name    = args[:name]

          filter if @name

          if @details
            details
          else
            summary
          end
        end

        private

        def filter
          @catalog.select! {|k| @name == k }
        end

        def summary
          @catalog.keys.join("\n")
        end

        def details
          @catalog.each_pair.map do |k,v|
            data = k + "\n"
            data << "  Regions       : " + @catalog[k]["regions"].join(", ") + "\n"
            data << "  Bucket Prefix : " + @catalog[k]["bucket_prefix"].first
          end
        end
      end
    end
  end
end
