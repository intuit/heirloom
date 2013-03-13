module Heirloom
  module Utils
    module Email

      def valid_email?(email)
         email =~ /^.*@.*\..*$/
      end

    end
  end
end
