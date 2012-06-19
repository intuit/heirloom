module Heirloom
  module CLI
    class Update

      def initialize(args)
        @name = args[:name]
        @id = args[:id]
        @logger = args[:logger]
        @attribute = args[:attribute]
        @update = args[:update]
        @artifact = Artifact.new :name      => @name,
                                 :id        => @id,
                                 :logger    => @logger
      end
      
      def update
        @artifact.update :attribute => @attribute,
                         :update    => @update
      end

    end
  end
end
