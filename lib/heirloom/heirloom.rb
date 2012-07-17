require 'heirloom/heirloom/lister.rb'
require 'heirloom/heirloom/reader.rb'
require 'heirloom/heirloom/builder.rb'
require 'heirloom/heirloom/updater.rb'
require 'heirloom/heirloom/uploader.rb'
require 'heirloom/heirloom/downloader.rb'
require 'heirloom/heirloom/authorizer.rb'
require 'heirloom/heirloom/destroyer.rb'
require 'heirloom/heirloom/verifier.rb'

module Heirloom

  class Heirloom

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

    def buckets_exist?(args)
      verifier.buckets_exist? args
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

    def verifier
      @verifier ||= Verifier.new :config => @config,
                                 :name   => @name
    end

  end
end
