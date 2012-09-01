require 'heirloom/catalog/add.rb'
require 'heirloom/catalog/create.rb'
require 'heirloom/catalog/delete.rb'
require 'heirloom/catalog/list.rb'
require 'heirloom/catalog/setup.rb'
require 'heirloom/catalog/verify.rb'

module Heirloom
  class Catalog
    def initialize(args)
      @config  = args[:config]
      @name    = args[:name]
      @regions = args[:regions]
    end

    def create_catalog_domain
      setup.create_catalog_domain
    end

    def add_to_catalog
      add.add_to_catalog
    end

    private

    def setup
      @setup ||= Catalog::Setup.new :config => @config
    end

    def add
      @add ||= Catalog::Add.new :config  => @config,
                                :name    => @name,
                                :regions => @regions
    end
  end
end
