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

        missing_opts.each {|missing_opt| logger.error missing_opt}

        missing_opts.empty?
      end

      def self.load_config(args)
        opts = args[:opts]
        logger = args[:logger]
        config = Config.new :logger => logger
        config.access_key = opts[:key] if opts[:key_given]
        config.secret_key = opts[:secret] if opts[:secret_given]
        config
      end

    end
  end
end
