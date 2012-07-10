module Heirloom
  module CLI
    class List

      def initialize(args)
        @artifact = Artifact.new :name   => args[:name],
                                 :logger => args[:logger]
      end
      
      def list(limit)
        @logger = Logger
        puts @artifact.list(limit)
      end

    end
  end
end
