module Heirloom
  module CLI
    module Shared

      def self.valid_options?(args)
        provided = args[:provided]
        required = args[:required]
        logger = args[:logger]

        missing_opts = required.map do |opt|
          case provided[opt]
          when nil
            "Option '#{opt} (-#{opt[0]})' required but not specified."
          when []
            "Option '#{opt} (-#{opt[0]})' required but not specified."
          end
        end

        missing_opts.compact!

        if missing_opts.any?
          missing_opts.each {|missing_opt| logger.error missing_opt}
        end

        missing_opts.any? ? false : true

      end

    end
  end
end
