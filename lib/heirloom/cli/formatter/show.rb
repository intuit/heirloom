module Heirloom
  module CLI
    module Formatter
      class Show

        def display(args)
          @attributes = args[:attributes]
          remove_internal_attributes
          puts_attributes
        end

        private

        def puts_attributes
          max_length = longest_attribute
          @attributes.each_pair do |k,v|
            k = k + (" " * (max_length - k.length + 1))
            puts "#{k}: #{v}"
          end 
        end

        def longest_attribute
          longest_key = 0
          @attributes.keys.each do |k|
            longest_key = k.length if k.length > longest_key
          end
          longest_key 
        end

        def remove_internal_attributes
          @attributes.delete_if { |key| internal?(key) }
        end

        def internal?(attribute)
          return true if reserved? attribute
          return true if endpoint? attribute
          false
        end

        def reserved?(attribute)
          ['bucket_prefix', 'built_at', 'built_by'].include? attribute
        end
        
        def endpoint?(attribute)
          attribute.match('^.*-.*-\d*-s3|http|https-url$')
        end
      end
    end
  end
end
