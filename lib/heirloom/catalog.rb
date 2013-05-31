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

    def cleanup(opts = {})
      opts[:num_to_keep]      ||= 100
      opts[:remove_preserved] ||= false

      num_cleaned = 0

      q = "select * from `#{domain}` where built_at > '2000-01-01T00:00:00.000Z' order by built_at desc"

      sdb.select(q, :offset => opts[:num_to_keep]) do |key, item|
        unless opts[:remove_preserved]
          next if preserved?(item)
        end

        archive = Archive.new :config => @config, :name => @name, :id => key
        archive.destroy
        num_cleaned += 1
      end

      if num_cleaned == 0
        Heirloom.log.info "No archives to delete."
      else
        Heirloom.log.info "#{num_cleaned} archive#{'s' unless num_cleaned == 1} deleted."
      end
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

    def preserved?(item)
      item['preserve'] && item['preserve'].include?('true')
    end

    def sdb
      @sdb ||= Heirloom::AWS::SimpleDB.new :config => @config
    end

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

    def domain
      "heirloom_#{@name}"
    end

  end
end
