module Heirloom
  module CLI
    class Build

      def initialize(args)
        @name = args[:name]
        @id = args[:id]
        @accounts = args[:accounts]
        @bucket_prefix = args[:bucket_prefix]
        @directory = args[:directory]
        @exclude = args[:exclude].split(',')
        @public = args[:public]
        @git = args[:git]
        @logger = args[:logger]
        @artifact = Artifact.new :name   => @name,
                                 :id     => @id,
                                 :logger => @logger
      end
      
      def build
        @artifact.destroy if @artifact.exists?
                          
        file = @artifact.build :accounts       => @accounts,
                               :bucket_prefix  => @bucket_prefix,
                               :directory      => @directory,
                               :exclude        => @exclude,
                               :public         => @public,
                               :git            => @git

        @artifact.upload :bucket_prefix    => @bucket_prefix,
                         :file             => file

        @artifact.authorize unless @public

        @artifact.cleanup
      end

    end
  end
end
