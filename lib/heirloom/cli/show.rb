module Heirloom
  module CLI
    class Show

      def initialize(args)
        @artifact = Artifact.new :name   => args[:name],
                                 :id     => args[:id],
                                 :logger => args[:logger]
      end
      
      def show
        @logger = Logger
        puts @artifact.show.to_yaml
      end

    end
  end
end
