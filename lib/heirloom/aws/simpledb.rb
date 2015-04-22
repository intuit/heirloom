require 'fog'
require 'retries'

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
        with_retries(:max_retries => 3,
                     :rescue => Excon::Errors::ServiceUnavailable,
                     :base_sleep_seconds => 10,
                     :max_sleep_seconds => 60) do
          @sdb.list_domains.body['Domains']
        end
      end

      def domain_exists?(domain)
        domains.include? domain
      end

      def create_domain(domain)
        with_retries(:max_retries => 3,
                     :rescue => Excon::Errors::ServiceUnavailable,
                     :base_sleep_seconds => 10,
                     :max_sleep_seconds => 60) do
          @sdb.create_domain(domain) unless domain_exists?(domain)
        end
      end

      def delete_domain(domain)
        with_retries(:max_retries => 3,
                     :rescue => Excon::Errors::ServiceUnavailable,
                     :base_sleep_seconds => 10,
                     :max_sleep_seconds => 60) do
          @sdb.delete_domain(domain)
        end
      end

      def domain_empty?(domain)
        count(domain).zero?
      end

      def put_attributes(domain, key, attributes, options = {})
        with_retries(:max_retries => 3,
                     :rescue => Excon::Errors::ServiceUnavailable,
                     :base_sleep_seconds => 10,
                     :max_sleep_seconds => 60) do
          @sdb.put_attributes domain, key, attributes, options
        end
      end

      def select(query, opts = {})
        has_more   = true
        next_token = nil
        results    = {}

        logger.debug "Executing simpledb query '#{query}'."

        if opts[:offset] && opts[:offset] > 0
          limit = with_retries(:max_retries => 3,
                               :rescue => Excon::Errors::ServiceUnavailable,
                               :base_sleep_seconds => 10,
                               :max_sleep_seconds => 60) do
            @sdb.select("#{query} limit #{opts[:offset]}").body
          end
          if limit['NextToken']
            logger.debug "Next token found. Retrieving results."
            next_token = limit['NextToken']
          else
            logger.debug "No more results. Query complete."
            has_more = false
          end
        end

        while has_more
          logger.debug "Retrieving results from next token '#{next_token}'." if next_token
          more = with_retries(:max_retries => 3,
                              :rescue => Excon::Errors::ServiceUnavailable,
                              :base_sleep_seconds => 10,
                              :max_sleep_seconds => 60) do
            @sdb.select(query, 'NextToken' => next_token).body
          end
          more['Items'].each do |k, v|
            block_given? ? yield(k, v) : results[k] = v
          end
          if more['NextToken']
            logger.debug "Next token found. Retrieving results."
            next_token = more['NextToken']
          else
            logger.debug "No more results. Query complete."
            has_more = false
          end
        end
        results unless block_given?
      end

      def delete(domain, key)
        with_retries(:max_retries => 3,
                     :rescue => Excon::Errors::ServiceUnavailable,
                     :base_sleep_seconds => 10,
                     :max_sleep_seconds => 60) do
          @sdb.delete_attributes domain, key
        end
      end

      def count(domain)
        with_retries(:max_retries => 3,
                     :rescue => Excon::Errors::ServiceUnavailable,
                     :base_sleep_seconds => 10,
                     :max_sleep_seconds => 60) do
          body = @sdb.select("SELECT count(*) FROM `#{domain}`").body
          body['Items']['Domain']['Count'].first.to_i
        end
      end

      def item_count(domain, item)
        with_retries(:max_retries => 3,
                     :rescue => Excon::Errors::ServiceUnavailable,
                     :base_sleep_seconds => 10,
                     :max_sleep_seconds => 60) do
          query = "SELECT count(*) FROM `#{domain}` WHERE itemName() = '#{item}'"
          @sdb.select(query).body['Items']['Domain']['Count'].first.to_i
        end
      end

      def logger
        @logger
      end

    end
  end

end
