require 'tempfile'

module Heirloom
  module Cipher
    module Shared

      include Heirloom::Utils::File

      def gpg_in_path?
        unless which('gpg')
          @logger.error "gpg not found in path."
          return false
        end
        true
      end

    end
  end
end
