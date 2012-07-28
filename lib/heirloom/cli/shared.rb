module Heirloom
  module CLI
    module Shared

      def self.valid_options?(args)
        provided = args[:provided]
        required = args[:required]

        required.each do |opt|
          unless provided[opt]
            puts "Option '#{opt} (-#{opt[0]})' required but not specified."
            exit 1
          end
        end

      end

    end
  end
end
