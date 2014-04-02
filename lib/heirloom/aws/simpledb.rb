require 'fog'

module Heirloom
  module AWS
    class SimpleDB

      def initialize(args)
        @config = args[:config]
        @logger = @config.logger

        fog_args = { :region => @config.metadata_region }

        if @config.use_iam_profile
          fog_args[:use_iam_profile] = true
        else
          fog_args[:aws_access_key_id]     = @config.access_key
          fog_args[:aws_secret_access_key] = @config.secret_key
        end

        @sdb = Fog::AWS::SimpleDB.new fog_args
      end

      def domains
        @sdb.list_domains.body['Domains']
      end

      def domain_exists?(domain)
        domains.include? domain
      end

      def create_domain(domain)
        @sdb.create_domain(domain) unless domain_exists?(domain)
      end

      def delete_domain(domain)
        @sdb.delete_domain(domain)
      end

      def domain_empty?(domain)
        count(domain).zero?
      end

      def put_attributes(domain, key, attributes, options = {})
        @sdb.put_attributes domain, key, attributes, options
      end

      def select(query, opts = {})
        has_more   = true
        next_token = nil
        results    = {}

        logger.debug "Executing simpledb query '#{query}'."

        if opts[:offset] && opts[:offset] > 0
          limit = @sdb.select("#{query} limit #{opts[:offset]}").body
          if limit['NextToken']
            logger.debug "Next token found. Retrieving results"
            next_token = limit['NextToken']
          else
            logger.debug "No more results."
            has_more = false
          end
        end

        while has_more
          logger.debug "Retrieving results from next token '#{next_token}'." if next_token
          more = @sdb.select(query, 'NextToken' => next_token).body
          more['Items'].each do |k, v|
            block_given? ? yield(k, v) : results[k] = v
          end
          if more['NextToken']
            logger.debug "Next token found. Retrieving results"
            next_token = more['NextToken']
          else
            logger.debug "No More results."
            has_more = false
          end
        end
        results unless block_given?
      end

      def delete(domain, key)
        @sdb.delete_attributes domain, key
      end

      def count(domain)
        body = @sdb.select("SELECT count(*) FROM `#{domain}`").body
        body['Items']['Domain']['Count'].first.to_i
      end

      def item_count(domain, item)
        query = "SELECT count(*) FROM `#{domain}` WHERE itemName() = '#{item}'"
        @sdb.select(query).body['Items']['Domain']['Count'].first.to_i
      end

      def logger
        @logger
      end

    end
  end

end
