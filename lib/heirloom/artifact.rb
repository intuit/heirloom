require 'heirloom/artifact/artifact_lister.rb'
require 'heirloom/artifact/artifact_reader.rb'
require 'heirloom/artifact/artifact_builder.rb'
require 'heirloom/artifact/artifact_updater.rb'
require 'heirloom/artifact/artifact_uploader.rb'
require 'heirloom/artifact/artifact_downloader.rb'
require 'heirloom/artifact/artifact_authorizer.rb'
require 'heirloom/artifact/artifact_destroyer.rb'

module Heirloom

  class Artifact

    def initialize(args)
      @config = Config.new :config => args[:config]
      @logger = args[:logger]
      @name = args[:name]
      @id = args[:id]
    end

    def build(args)
      artifact_builder.build args
    end

    def authorize(args)
      artifact_authorizer.authorize args
    end

    def upload(args)
      artifact_uploader.upload args
    end

    def update(args)
      artifact_updater.update args
    end

    def download(args)
      artifact_downloader.download args
    end

    def exists?
      artifact_reader.exists?
    end

    def destroy
      artifact_destroyer.destroy
    end

    def show
      artifact_reader.show
    end

    def list
      artifact_lister.list
    end

    def cleanup
      artifact_builder.cleanup
    end

    private

    def artifact_lister
      @artifact_lister ||= ArtifactLister.new :config => @config,
                                              :name   => @name
    end

    def artifact_reader
      @artifact_reader ||= ArtifactReader.new :config => @config,
                                              :name   => @name,
                                              :id     => @id
    end

    def artifact_builder
      @artifact_builder ||= ArtifactBuilder.new :config => @config,
                                                :logger => @logger,
                                                :name   => @name,
                                                :id     => @id
    end

    def artifact_updater
      @artifact_updater ||= ArtifactUpdater.new :config => @config,
                                                :logger => @logger,
                                                :name   => @name,
                                                :id     => @id
    end

    def artifact_uploader
      @artifact_uploader ||= ArtifactUploader.new :config => @config,
                                                  :logger => @logger,
                                                  :name   => @name,
                                                  :id     => @id
    end

    def artifact_downloader
      @artifact_downloader ||= ArtifactDownloader.new :config => @config,
                                                      :logger => @logger,
                                                      :name   => @name,
                                                      :id     => @id
    end

    def artifact_authorizer
      @artifact_authorizer ||= ArtifactAuthorizer.new :config => @config,
                                                      :logger => @logger,
                                                      :name   => @name,
                                                      :id     => @id
    end

    def artifact_destroyer
      @artifact_destroyer ||= ArtifactDestroyer.new :config => @config,
                                                    :logger => @logger,
                                                    :name   => @name,
                                                    :id     => @id
    end

  end
end
