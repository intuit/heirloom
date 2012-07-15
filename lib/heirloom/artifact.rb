require 'heirloom/artifact/lister.rb'
require 'heirloom/artifact/reader.rb'
require 'heirloom/artifact/builder.rb'
require 'heirloom/artifact/updater.rb'
require 'heirloom/artifact/uploader.rb'
require 'heirloom/artifact/downloader.rb'
require 'heirloom/artifact/authorizer.rb'
require 'heirloom/artifact/destroyer.rb'

module Heirloom

  class Artifact

    def initialize(args)
      @config = Config.new :config => args[:config],
                           :logger => args[:logger]
      @name = args[:name]
      @id = args[:id]
    end

    def authorize
      authorizer.authorize
    end

    def build(args)
      builder.build args
    end

    def download(args)
      downloader.download args
    end

    def update(args)
      updater.update args
    end

    def upload(args)
      uploader.upload args
    end

    def exists?
      reader.exists?
    end

    def destroy
      destroyer.destroy
    end

    def show
      reader.show
    end

    def list(limit=10)
      lister.list(limit)
    end

    def cleanup
      builder.cleanup
    end

    private

    def lister
      @lister ||= Lister.new :config => @config,
                                              :name   => @name
    end

    def reader
      @reader ||= Reader.new :config => @config,
                                              :name   => @name,
                                              :id     => @id
    end

    def builder
      @builder ||= Builder.new :config => @config,
                                                :name   => @name,
                                                :id     => @id
    end

    def updater
      @updater ||= Updater.new :config => @config,
                                                :name   => @name,
                                                :id     => @id
    end

    def uploader
      @uploader ||= Uploader.new :config => @config,
                                                  :name   => @name,
                                                  :id     => @id
    end

    def downloader
      @downloader ||= Downloader.new :config => @config,
                                                      :name   => @name,
                                                      :id     => @id
    end

    def authorizer
      @authorizer ||= Authorizer.new :config => @config,
                                                      :name   => @name,
                                                      :id     => @id
    end

    def destroyer
      @destroyer ||= Destroyer.new :config => @config,
                                                    :name   => @name,
                                                    :id     => @id
    end

  end
end
