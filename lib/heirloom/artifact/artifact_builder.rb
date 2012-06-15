require 'socket'
require 'time'

module Heirloom

  class ArtifactBuilder

    def initialize(args)
      @config = args[:config]
      @logger = args[:logger]
    end

    def build(args)
      @name = args[:name]
      @id = args[:id]
      @public = args[:public]
      @git_directory = GitDirectory.new :directory => args[:directory],
                                        :logger => @logger
                                        
      @commit = @git_directory.commit @id

      create_artifact_record
      @git_directory.build_artifact_from_directory
    end

    private

    def create_artifact_domain
      @logger.info "Verifying artifact domain #{@name} exists."
      sdb.create_domain @name
    end

    def create_artifact_record
      create_artifact_domain
      attributes = { 'built_by'        => "#{user}@#{hostname}",
                     'built_at'        => Time.now.utc.iso8601,
                     'sha'             => @id,
                     'abbreviated_sha' => @commit.id_abbrev,
                     'message'         => @commit.message,
                     'author'          => @commit.author.name }
      sdb.put_attributes @name, @id, attributes
    end

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
