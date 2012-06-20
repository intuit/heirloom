require 'socket'
require 'time'

module Heirloom

  class ArtifactBuilder

    attr_accessor :config, :id, :local_build, :logger, :name, :source

    def initialize(args)
      self.config = args[:config]
      self.name = args[:name]
      self.id = args[:id]
      self.logger = config.logger
    end

    def build(args)
      self.source = args[:directory] ||= '.'

      directory = Directory.new :path      => source,
                                :exclude   => args[:exclude],
                                :config    => config

      directory.build_artifact_from_directory

      self.local_build = directory.local_build

      create_artifact_record

      add_git_commit if args[:git]

      logger.info "Build complete."

      local_build
    end

    def cleanup
      logger.info "Cleaning up local build #{local_build}."
      File.delete local_build
    end

    private

    def add_git_commit
      git_commit = GitDirectory.new(:path => source).commit
      add_git_commit_to_artifact_record git_commit
    end

    def create_artifact_domain
      logger.info "Verifying artifact domain #{name} exists."
      sdb.create_domain name
    end

    def create_artifact_record
      create_artifact_domain
      attributes = { 'built_by'        => "#{user}@#{hostname}",
                     'built_at'        => Time.now.utc.iso8601,
                     'id'              => id }
      logger.info "Create artifact record #{id}."
      sdb.put_attributes name, id, attributes
    end

    def add_git_commit_to_artifact_record(commit)
      attributes = { 'sha'             => id,
                     'abbreviated_sha' => commit.id_abbrev,
                     'message'         => commit.message,
                     'author'          => commit.author.name }

      logger.info "Git sha: #{id}"
      logger.info "Git abbreviated_sha: #{commit.id_abbrev}"
      logger.info "Git message: #{commit.message}"
      logger.info "Git author: #{commit.author.name}"

      sdb.put_attributes name, id, attributes
    end

    def sdb
      @sdb ||= AWS::SimpleDB.new :config => config
    end

    def user
      ENV['USER']
    end

    def hostname
      Socket.gethostname
    end

  end
end
