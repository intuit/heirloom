module Heirloom
  module CLI
    class Destroy

      def initialize(args)
        @name = args[:name]
        @id = args[:id]
        @logger = args[:logger]
        @artifact = Artifact.new :name   => @name,
                                 :id     => @id,
                                 :logger => @logger
      end
      
      def destroy
        @artifact.destroy
      end

    end
  end
end
