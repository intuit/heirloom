module Heirloom
  module CLI
    class Download

      def initialize(args)
        @name = args[:name]
        @id = args[:id]
        @output = args[:output]
        @region = args[:region]
        @logger = args[:logger]
        @artifact = Artifact.new :name      => @name,
                                 :id        => @id,
                                 :logger    => @logger
      end
      
      def download
        @artifact.download :output => @output,
                           :region => @region
      end

    end
  end
end
