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
  class Artifact
    attr_accessor :artifact_type, :commit, :source_dirs,
                  :access_key, :secret_key, :sdb

    def initialize(args)
      self.artifact_type = args[:artifact_type]
      self.access_key = args[:access_key]
      self.secret_key = args[:secret_key]
      self.source_dir = args[:source_dir]
      self.sdb = connect_to_sdb
    end

    def build_artifact_and_upload_to_s3(args)
      get_commit args[:sha]
      build_local_artifact
      create_sdb_record
      upload_to_s3
      delete_local_artifact
    end

    protected

    def get_commit(sha = nil)
      r = Repo.new source_dir
      if sha
        self.commit = r.commits(sha)
      else
        self.commit = r.commits.first
      end
    end

    def build_local_artifact
      tgz = Zlib::GzipWriter.new(File.open(artifact_path, 'wb'))
      Minitar.pack('.', tgz)
    end

    def delete_local_artifact
      File.delete(artifact_path)
    end

    def create_sdb_domain
      sdb.create_domain(domain) unless sdb.list_domains.body['Domains'].include? domain
    end

    def create_sdb_record
      create_sdb_domain 
      sdb.put_attributes domain, sha, { 'built_by' => "#{user}@#{hostname}",
                                        'built_at' => Time.now.utc.iso8601,
                                        'tests' => 'pending',
                                        'sha' => sha,
                                        'abbreviated_sha' => abbreviated_sha,
                                        'message' => message,
                                        'author' => author }
    end

    def upload_to_s3
      target_buckets = buckets

      # Upload the artifact to each bucket
      target_buckets.each_pair do |bucket, options|

        # Connect to s3 in region of bucket
        region = options['region']
        connection = Fog::Storage.new :provider                 => 'AWS',
                                      :aws_access_key_id        => access_key,
                                      :aws_secret_access_key    => secret_key,
                                      :region                   => region

        # Get bucket
        b = connection.directories.get bucket

        # Upload the artifact
        b.files.create :key    => "#{folder}/#{artifact}",
                       :body   => File.open(artifact_path),
                       :public => false
                       
        # Add the artifact location
        sdb.put_attributes domain, sha, { "#{region}-s3-url" => "s3://#{bucket}/#{folder}/#{artifact}" }

        # Add the http url
        sdb.put_attributes domain, sha, { "#{region}-http-url" => "http://#{bucket}/#{folder}/#{artifact}" }

        # Add the https url
        sdb.put_attributes domain, sha, { "#{region}-https-url" => "https://#{bucket}/#{folder}/#{artifact}" }
      end
    end

    private

    def buckets
      { 
        'intu-lc-us-west-1' => { 
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
      artifact_type
    end

    def folder
      artifact_type
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

    def connect_to_sdb
      raise 'Please supply credentials' unless access_key && secret_key
      sdb = Fog::AWS::SimpleDB.new :aws_access_key_id => access_key,
                                   :aws_secret_access_key => secret_key,
                                   :region => 'us-west-1'
    end
  end
end
