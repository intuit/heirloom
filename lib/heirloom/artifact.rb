require 'heirloom/artifact/artifact_lister.rb'
require 'heirloom/artifact/artifact_reader.rb'
require 'heirloom/artifact/artifact_builder.rb'
require 'heirloom/artifact/artifact_uploader.rb'
require 'heirloom/artifact/artifact_authorizer.rb'
require 'heirloom/artifact/artifact_destroyer.rb'

module Heirloom

  class Artifact
    def initialize(args)
      @config = Config.new :config => args[:config]
      @logger = args[:logger] ||= Logger.new(STDOUT)
    end

    def build(args)
      if artifact_reader.exists?(args)
        @logger.info "Destroying existing artifact."
        destroy(args)
      end

      file = artifact_builder.build(args)

      @logger.info "Uploading artifact."
      artifact_uploader.upload :id              => args[:id],
                               :name            => args[:name],
                               :file            => file,
                               :public_readable => args[:public]

      @logger.info "Authorizing accounts."
      artifact_authorizer.authorize :id               => args[:id],
                                    :name             => args[:name],
                                    :public_readable  => args[:public_readable]
    end

    def destroy(args)
      @logger.info "Destroying #{args[:name]} - #{args[:id]}"
      artifact_destroyer.destroy(args)
    end

    def show(args)
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

    def artifact_builder
      @artifact_builder ||= ArtifactBuilder.new :config => @config
    end

    def artifact_uploader
      @artifact_uploader ||= ArtifactUploader.new :config => @config
    end

    def artifact_authorizer
      @artifact_authorizer ||= ArtifactAuthorizer.new :config => @config
    end

    def artifact_destroyer
      @artifact_destroyer ||= ArtifactDestroyer.new :config => @config
    end

  end
end
