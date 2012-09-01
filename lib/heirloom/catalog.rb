require 'heirloom/catalog/add.rb'
require 'heirloom/catalog/create.rb'
require 'heirloom/catalog/delete.rb'
require 'heirloom/catalog/list.rb'
require 'heirloom/catalog/setup.rb'
require 'heirloom/catalog/verify.rb'

module Heirloom
  class Catalog
    def initialize(args)
      @config = args[:config]
      @name   = args[:name]
    end

    def setup
      setup.create_catalog_domain
    end

    private

    def setup
      @setup ||= Catalog::Setup.new :config => @config,
                                    :name   => @name
    end
  end
end
