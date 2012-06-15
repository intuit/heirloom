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

    def show(args)
      puts args
      artifact_reader.show(args)
    end

    def versions(args)
      artifact_lister.versions(args)
    end

    def list
      artifact_lister.list
    end

    private

    def artifact_lister
      @artifact_lister ||= ArtifactLister.new :config => @config
    end

    def artifact_reader
      @artifact_reader ||= ArtifactReader.new :config => @config
    end

  end
end
