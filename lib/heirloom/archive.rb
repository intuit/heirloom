require 'heirloom/archive/lister.rb'
require 'heirloom/archive/reader.rb'
require 'heirloom/archive/builder.rb'
require 'heirloom/archive/updater.rb'
require 'heirloom/archive/uploader.rb'
require 'heirloom/archive/downloader.rb'
require 'heirloom/archive/setuper.rb'
require 'heirloom/archive/writer.rb'
require 'heirloom/archive/authorizer.rb'
require 'heirloom/archive/destroyer.rb'
require 'heirloom/archive/verifier.rb'

module Heirloom

  class Archive

    def initialize(args)
      @config = args[:config]
      @name   = args[:name]
      @id     = args[:id]
    end

    def authorize(accounts)
      authorizer.authorize :accounts => accounts,
                           :regions  => regions
    end

    def build(args)
      builder.build args
    end

    def count
      reader.count
    end

    def download(args)
      downloader.download args
    end

    def setup(args)
      setuper.setup args
    end

    def update(args)
      updater.update args
    end

    def upload(args)
      uploader.upload({ :regions => regions }.merge(args))
    end

    def exists?
      reader.exists?
    end

    def buckets_exist?(args)
      verifier.buckets_exist? args
    end

    def domain_exists?
      verifier.domain_exists?
    end

    def destroy(args)
      destroyer.destroy :regions     => regions,
                        :keep_domain => args[:keep_domain]
    end

    def show
      reader.show
    end

    def list(limit=10)
      lister.list(limit)
    end

    def regions
      reader.regions
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

    def setuper
      @setuper ||= Setuper.new :config => @config,
                               :name   => @name
    end

    def verifier
      @verifier ||= Verifier.new :config => @config,
                                 :name   => @name
    end

  end
end
