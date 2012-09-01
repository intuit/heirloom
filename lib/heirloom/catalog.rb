require 'heirloom/catalog/add.rb'
require 'heirloom/catalog/delete.rb'
require 'heirloom/catalog/setup.rb'
require 'heirloom/catalog/show.rb'
require 'heirloom/catalog/verify.rb'

module Heirloom
  class Catalog

    def initialize(args)
      @config  = args[:config]
      @name    = args[:name]
    end

    def create_catalog_domain
      setup.create_catalog_domain
    end

    def add_to_catalog(args)
      add.add_to_catalog(args)
    end

    def regions
      show.regions
    end

    def base
      show.base
    end

    private

    def setup
      @setup ||= Catalog::Setup.new :config => @config
    end

    def add
      @add ||= Catalog::Add.new :config  => @config,
                                :name    => @name
    end

    def show
      @show ||= Catalog::Show.new :config  => @config,
                                  :name    => @name
    end
  end
end
