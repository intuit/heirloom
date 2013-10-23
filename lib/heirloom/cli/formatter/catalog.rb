module Heirloom
  module CLI
    module Formatter
      class Catalog
        def format(args)
          @catalog = args[:catalog]
          @name    = args[:name]
          @region  = args[:region]

          return @region, summary unless @name

          return false unless name_exists?

          filter_by_name
          details
        end

        private

        def remove_heirloom_prefix
          Hash[@catalog.sort.map { |k, v| [k.sub(/heirloom_/, ''), v] }]
        end

        def add_indent_prefix
          Hash[remove_heirloom_prefix.sort.map { |k, v| [k.sub(/^/, '  '), v] }]
        end

        def name_exists?
          @catalog.include? "heirloom_#{@name}"
        end

        def filter_by_name
          @catalog.select! {|k| "heirloom_#{@name}" == k }
        end

        def summary
          add_indent_prefix.keys.join "\n"
        end

        def details
          @catalog = remove_heirloom_prefix
          data = @catalog.each_pair.map do |k,v|
            urls = v["regions"].sort.map do |region|
              bucket_prefix = v["bucket_prefix"].first
              "  #{region}-s3-url : s3://#{bucket_prefix}-#{region}/#{k}"
            end

            d = k + "\n"
            d << "  metadata_region  : #{@region}\n"
            d << "  regions          : " + @catalog[k]["regions"].sort.join(", ") + "\n"
            d << "  bucket_prefix    : " + @catalog[k]["bucket_prefix"].first + "\n"
            d << urls.join("\n")
          end
          data.join "\n"
        end
      end
    end
  end
end
