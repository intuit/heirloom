module Heirloom
  module CLI
    class Show

      def initialize(args)
        id = args[:id] ? args[:id] : latest_id(args)
        @artifact = Artifact.new :name   => args[:name],
                                 :id     => id,
                                 :logger => args[:logger]
      end
      
      def show
        @logger = Logger
        puts @artifact.show.to_yaml
      end

      private

      def latest_id(args)
        @artifact = Artifact.new :name   => args[:name],
                                 :logger => args[:logger]
        @artifact.list(1).first
      end

    end
  end
end
