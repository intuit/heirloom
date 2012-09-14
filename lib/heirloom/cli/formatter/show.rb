module Heirloom
  module CLI
    module Formatter
      class Show

        def display(args)
          @attributes = args[:attributes]
          @system     = args[:system]
          remove_internal_attributes
          puts_attributes
        end

        private

        def puts_attributes
          @attributes.each_pair do |key,value|
            Kernel.puts "#{padded_key(key)}: #{value}"
          end 
        end

        def padded_key(key)
          max_length ||= longest_attribute
          key + (" " * (max_length - key.length + 1))
        end

        def longest_attribute
          longest_key = 0
          @attributes.keys.each do |k|
            longest_key = k.length if k.length > longest_key
          end
          longest_key 
        end

        def remove_internal_attributes
          @attributes.delete_if { |key| internal_attribute?(key) }
        end

        def internal_attribute?(attribute)
          return true if is_reserved? attribute
          return true if is_endpoint? attribute
          false
        end

        def is_reserved?(attribute)
          ['bucket_prefix', 'base',
           'built_at', 'built_by'].include? attribute
        end
        
        def is_endpoint?(attribute)
          attribute.match('^.*-.*-\d*-s3|http|https-url$')
        end
      end
    end
  end
end
