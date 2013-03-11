module Heirloom
  module Utils
    module Email

      def valid_email?(email)
         email_pattern = (email =~ /^.*@.*\..*$/)
         email_pattern.nil? ? false : true
      end

    end
  end
end
