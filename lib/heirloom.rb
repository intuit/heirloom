require "heirloom/aws"
require "heirloom/version"

require 'socket'
require 'fog'
require 'grit'
require 'logger'
require 'time'
require 'zlib'
require 'archive/tar/minitar'
include Archive::Tar
include Grit

module Heirloom

  class Heirloom
    attr_accessor :heirloom_type, :commit, :source_dir, :prefix

    def self.list
      sdb = self.connect_to_sdb

      r = {}

      sdb.domains.each do |domain|
        r[domain] = sdb.select("select * from #{domain}")
      end

      r
    end

    def self.info(args)
      sdb = self.connect_to_sdb

      sdb.select("select * from #{args[:class]} where itemName() = '#{args[:sha]}'")
    end

    def self.delete(args)
      sdb = self.connect_to_sdb

      sdb.delete args[:class], args[:sha]
    end

    def self.connect_to_sdb
      @access_key = ENV['AWS_ACCESS_KEY_ID']
      @secret_key = ENV['AWS_SECRET_ACCESS_KEY']

      AWS::SimpleDb.new(@access_key, @secret_key)
    end

    def initialize(args)
      @sdb = self.class.connect_to_sdb

      self.heirloom_type = args[:heirloom_type]
      self.source_dir = args[:source_dir]
      self.prefix = args[:prefix]
    end

    def build_and_upload_to_s3(args)
      get_commit args[:sha]
      raise 'Artifact already uploaded to S3' if already_in_sdb?
      build_local_artifact
      create_sdb_record
      upload_to_s3
      delete_local_artifact
    end

    protected

    def get_commit(sha = nil)
      r = Repo.new source_dir
      if sha
        self.commit = r.commits(sha).first
      else
        self.commit = r.commits.first
      end
    end

    def build_local_artifact
      tgz = Zlib::GzipWriter.new File.open(artifact_path, 'wb')
      Minitar.pack(source_dir, tgz)
    end

    def delete_local_artifact
      File.delete(artifact_path)
    end

    def create_sdb_domain
      @sdb.create_domain(domain)
    end

    def create_sdb_record
      create_sdb_domain 
      @sdb.put_attributes domain, sha, { 'built_by' => "#{user}@#{hostname}",
                                         'built_at' => Time.now.utc.iso8601,
                                         'tests' => 'pending',
                                         'sha' => sha,
                                         'abbreviated_sha' => abbreviated_sha,
                                         'message' => message,
                                         'author' => author }
    end

    def already_in_sdb?
      @sdb.select("select * from #{domain} where itemName() = '#{sha}'").count > 0
    end

    def upload_to_s3
      target_buckets = buckets

      # Upload the artifact to each bucket
      target_buckets.each_pair do |bucket, options|

        # Connect to s3 in region of bucket
        region = options['region']
        connection = Fog::Storage.new :provider                 => 'AWS',
                                      :aws_access_key_id        => ENV['AWS_ACCESS_KEY_ID'],
                                      :aws_secret_access_key    => ENV['AWS_SECRET_ACCESS_KEY'],
                                      :region                   => region

        # Get bucket
        b = connection.directories.get bucket

        # Upload the artifact
        b.files.create :key    => "#{folder}/#{artifact}",
                       :body   => File.open(artifact_path),
                       :public => false
                       
        # Add the artifact location
        @sdb.put_attributes domain, sha, { "#{region}-s3-url" => "s3://#{bucket}/#{folder}/#{artifact}" }

        # Add the http url
        @sdb.put_attributes domain, sha, { "#{region}-http-url" => "http://#{bucket}/#{folder}/#{artifact}" }

        # Add the https url
        @sdb.put_attributes domain, sha, { "#{region}-https-url" => "https://#{bucket}/#{folder}/#{artifact}" }
      end
    end

    private

    def buckets
      {
        "#{prefix}-us-west-1" => { 
          'region' => 'us-west-1'
        }
      }
    end

    def artifact
      "#{sha}.tar.gz"
    end

    def artifact_path
      "/tmp/#{artifact}"
    end

    def domain
      heirloom_type
    end

    def folder
      heirloom_type
    end

    def author
      commit.author.name
    end

    def message
      commit.message
    end
    
    def sha
      commit.id
    end

    def abbreviated_sha
      commit.id_abbrev
    end

    def user
      ENV['USER']
    end

    def hostname
      Socket.gethostname
    end

  end
end
