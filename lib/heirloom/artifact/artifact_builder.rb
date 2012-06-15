require 'socket'
require 'time'

module Heirloom

  class ArtifactBuilder

    def initialize(args)
      @config = args[:config]
    end

    def build(args)
      @name = args[:name]
      @id = args[:id]
      @public = args[:public]
      @git_directory = GitDirectory.new args[:directory]
      @commit = @git_directory.commit @id

      create_domain @name
      artifact_fil = @git_directory.build_artifact_from_directory
      create_artifact_record
      upload_artifact :file => artifact_file,
                      :public => @public
    end

    def create_artifact_domain
      sdb.create_domain @name
    end

    def create_artifact_record
      sdb.put_attributes domain, @id, { 'built_by'        => "#{user}@#{hostname}",
                                        'built_at'        => Time.now.utc.iso8601,
                                        'sha'             => @id,
                                        'abbreviated_sha' => @commit.abbreviated_sha
                                        'message'         => @commit.message,
                                        'author'          => @commit.author }
    end

    def upload_artifact(args)
      @config.regions.each do |region|
        s3_uploader = Uploader::S3.new :config => @config,
                                       :region => region

        s3_uploader.upload_file :file => args[:file]
                                :key_name => @id,
                                :key_folder => @name,
      end
    end

    private

    def sdb
      @sdb ||= AWS::SimpleDB.new :config => @config
    end

    def user
      ENV['USER']
    end

    def hostname
      Socket.gethostname
    end

  end
end
