module Heirloom
  module CLI
    module Formatter
      class Show
        def initialize(output)
          @output = output
        end

        def display
          puts @output
        end
      end
    end
  end
end
