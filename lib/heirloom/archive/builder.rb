require 'socket'
require 'time'

module Heirloom

  class Builder

    attr_writer :local_build

    def initialize(args)
      @config = args[:config]
      @name = args[:name]
      @domain = "heirloom_#{@name}"
      @id = args[:id]
      @logger = @config.logger
      sdb.create_domain @domain
    end

    def build(args)
      @source = args[:directory] ||= '.'

      directory = Directory.new :path      => @source,
                                :exclude   => args[:exclude],
                                :config    => @config

      unless directory.build_artifact_from_directory :secret => args[:secret]
        return false
      end

      @local_build = directory.local_build

      create_artifact_record

      add_git_commit if args[:git]

      @logger.info "Build complete."

      @local_build
    end

    private

    def add_git_commit
      git = GitDirectory.new(:path => @source)
      commit = git.commit @id
      if commit
        add_git_commit_to_artifact_record commit
      else
        @logger.warn "Could not load Git sha '#{@id}' in '#{@source}'."
      end
    end

    def add_git_commit_to_artifact_record(commit)
      attributes = { 'sha'             => @id,
                     'abbreviated_sha' => commit.id_abbrev,
                     'message'         => commit.message.gsub("\n"," "),
                     'author'          => commit.author.name }

      attributes.each_pair do |k, v|
        @logger.info "Git #{k}: #{v}"
      end

      sdb.put_attributes @domain, @id, attributes
    end

    def create_artifact_record
      attributes = { 'built_by' => "#{user}@#{hostname}",
                     'built_at' => Time.now.utc.iso8601,
                     'id'       => @id }
      @logger.info "Create artifact record #{@id}."
      sdb.put_attributes @domain, @id, attributes
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
