require 'heirloom/catalog/add.rb'
require 'heirloom/catalog/delete.rb'
require 'heirloom/catalog/list.rb'
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

    def catalog_domain_exists?
      verify.catalog_domain_exists?
    end

    def entry_exists_in_catalog?(entry)
      verify.entry_exists_in_catalog? entry
    end

    def delete_from_catalog
      delete.delete_from_catalog
    end

    def add_to_catalog(args)
      add.add_to_catalog args
    end

    def regions
      show.regions
    end

    def bucket_prefix
      show.bucket_prefix
    end

    def all
      list.all
    end

    private

    def add
      @add ||= Catalog::Add.new :config => @config,
                                :name   => @name
    end

    def delete
      @delete ||= Catalog::Delete.new :config => @config,
                                      :name   => @name
    end

    def list
      @list ||= Catalog::List.new :config => @config
    end

    def setup
      @setup ||= Catalog::Setup.new :config => @config
    end

    def show
      @show ||= Catalog::Show.new :config => @config,
                                  :name   => @name
    end

    def verify
      @verify ||= Catalog::Verify.new :config => @config
    end

  end
end
