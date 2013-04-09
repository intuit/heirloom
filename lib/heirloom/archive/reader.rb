module Heirloom

  class Reader

    def initialize(args)
      @config = args[:config]
      @name   = args[:name]
      @id     = args[:id]
      @domain = "heirloom_#{@name}"
      @logger = @config.logger
    end

    def exists?
      if domain_exists? && show.any?
        @logger.debug "Found entry for #{@id} in SimpleDB."
        true
      else
        @logger.debug "Entry for #{@id} not found in SimpleDB."
        false
      end
    end

    def regions
      data = show.keys.map do |key|
        key.gsub('-s3-url', '') if key =~ /-s3-url$/
      end
      data.compact
    end

    def get_bucket(args)
      @logger.debug "Looking for bucket in #{args[:region]} for #{@id}"
      url = get_url(args)
      if url
        bucket = url.gsub('s3://', '').split('/').first
        @logger.debug "Found bucket #{bucket}."
        bucket
      else
        @logger.debug "Bucket not found."
        nil
      end
    end

    def get_key(args)
      url = get_url(args)
      if url
        bucket_path = get_bucket :region => args[:region]
        bucket = url.gsub('s3://', '').gsub(bucket_path, '')
        bucket.slice!(0)
        bucket
      else
        nil
      end
    end

    def count
      sdb.count @domain
    end

    def show
      query = sdb.select "select * from `#{@domain}` where itemName() = '#{@id}'"
      items = query[@id] ? query[@id] : {}
      data = Hash.new.tap do |hash|
        items.each_pair.map do |key,value|
          hash[key] = value.first
        end
      end
    end

    def object_acls
      data = {}
      regions.each do |region|
        object_name = "#{@name}/#{key_name}"

        bucket = get_bucket :region => region

        s3_acl = AWS::S3.new :config => @config,
                             :region => region

        object_acl = s3_acl.get_object_acl :bucket      => bucket,
                                           :object_name => object_name

        object_acl.delete ("Owner")
        output = object_acl["AccessControlList"].map do |x|
          "#{x["Grantee"]["DisplayName"]}:#{x["Permission"]}".downcase
        end
        data.merge!"#{region}-permissions" => output.join(', ')
      end
      data
    end

    def key_name
      encrypted? ? "#{@id}.tar.gz.gpg" : "#{@id}.tar.gz"
    end

    private

    def encrypted?
      show['encrypted'] == 'true'
    end

    def domain_exists?
      sdb.domain_exists? @domain
    end

    def get_url(args)
      region = args[:region]

      return nil unless exists?
      @logger.debug "Looking for #{region} endpoint for #{@id}"
      url = "#{region}-s3-url"
      if show[url]
        @logger.debug "Found #{url} for #{@id}."
        show[url]
      else
        @logger.debug "#{region} endpoint for #{@id} not found."
        nil
      end
    end

    def sdb
      @sdb ||= AWS::SimpleDB.new :config => @config
    end

  end
end
