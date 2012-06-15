require 'heirloom/artifact/artifact_lister.rb'

require 'socket'
require 'fog'
require 'grit'
require 'logger'
require 'time'
require 'zlib'
require 'archive/tar/minitar'
include Archive::Tar
include Grit

module Heirloom

  class Artifact
    def initialize(args)
      @config = Config.new :config => args[:config]
    end

    def list(args)
      artifact_lister.all(args)
    end

    private

    def artifact_lister
      @artifact_lister ||= ArtifactLister.new :config => @config
    end

  end
end
