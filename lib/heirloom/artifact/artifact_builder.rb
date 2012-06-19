require 'socket'
require 'time'

module Heirloom

  class ArtifactBuilder

    def initialize(args)
      @config = args[:config]
      @logger = args[:logger]
      @name = args[:name]
      @id = args[:id]
    end

    def build(args)
      @exclude = args[:exclude]

      directory = args[:directory] ||= '.'

      @directory = Directory.new :directory => directory,
                                 :exclude   => @exclude,
                                 :logger    => @logger

      @local_build = @directory.build_artifact_from_directory

      create_artifact_record

      if args[:git]
        git_directory = GitDirectory.new :directory => directory,
                                         :logger    => @logger
        @logger.info "Adding git commit to attributes."
        @commit = git_directory.commit @id
        add_git_commit_to_artifact_record
      end

      @logger.info "Build complete."

      @local_build
    end

    def cleanup
      @logger.info "Cleaning up local build #{@local_build}."
      File.delete @local_build
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
                     'id'              => @id }
      @logger.info "Create artifact record #{@id}"
      sdb.put_attributes @name, @id, attributes
    end

    def add_git_commit_to_artifact_record
      attributes = { 'sha'             => @id,
                     'abbreviated_sha' => @commit.id_abbrev,
                     'message'         => @commit.message,
                     'author'          => @commit.author.name }
      @logger.info "Git sha: #{@id}"
      @logger.info "Git abbreviated_sha: #{@commit.id_abbrev}"
      @logger.info "Git message: #{@commit.message}"
      @logger.info "Git author: #{@commit.author.name}"

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
