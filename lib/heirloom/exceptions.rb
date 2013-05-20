module Heirloom
  module Exceptions

    class Base < RuntimeError
      attr_accessor :message

      def initialize(message="")
        @message = message
      end
    end

    class EnvironmentNotFound < Base
    end

    class RotateFailed < Base
    end
      
    class CleanupFailed < Base
    end
      
  end
end
