module Heirloom
  module CLI
    module Formatter
      class Show

        def format(args)
          @all        = args[:all]
          @attributes = args[:attributes]
          format_attributes
        end

        private

        def format_attributes
          remove_internal_attributes unless @all
          formated = @attributes.each_pair.map do |key,value|
            "#{padded_key(key)}: #{value}"
          end
          formated.join("\n")
        end

        def padded_key(key)
          max_length ||= longest_attribute_length
          key + (" " * (max_length - key.length + 1))
        end

        def longest_attribute_length
          longest_length = 0
          @attributes.keys.each do |k|
            longest_length = k.length if k.length > longest_length
          end
          longest_length 
        end

        def remove_internal_attributes
          @attributes.delete_if { |key| is_internal_attribute? key }
        end

        def is_internal_attribute?(attribute)
          return true if is_reserved? attribute
          return true if is_endpoint? attribute
          return true if is_perms? attribute
          false
        end

        def is_reserved?(attribute)
          ['bucket_prefix', 'built_at', 'built_by'].include? attribute
        end
        
        def is_endpoint?(attribute)
          attribute.match('^.*-.*-\d*-s3|http|https-url$')
        end

        def is_perms?(attribute)
          attribute.match('^.*perms')
        end
      end
    end
  end
end
