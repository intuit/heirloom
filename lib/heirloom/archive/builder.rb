require 'socket'
require 'time'

module Heirloom

  class Builder

    attr_writer :local_build

    def initialize(args)
      @config = args[:config]
      @name   = args[:name]
      @domain = "heirloom_#{@name}"
      @id     = args[:id]
      @logger = @config.logger
    end

    def build(args)
      @source        = args[:directory] ||= '.'
      @secret        = args[:secret]
      @bucket_prefix = args[:bucket_prefix]

      directory = Directory.new :path    => @source,
                                :exclude => args[:exclude],
                                :config  => @config

      unless directory.build_artifact_from_directory :secret => @secret
        return false
      end

      @local_build = directory.local_build

      create_artifact_record

      add_git_commit if args[:git]

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
                     'message'         => commit.message.gsub("\n"," ")[0..1023],
                     'author'          => commit.author.name }

      attributes.each_pair do |k, v|
        @logger.info "Git #{k}: #{v}"
      end

      sdb.put_attributes @domain, @id, attributes
    end

    def create_artifact_record
      attributes = { 'built_by'      => "#{user}@#{hostname}",
                     'built_at'      => Time.now.utc.iso8601,
                     'encrypted'     => encrypted?,
                     'bucket_prefix' => @bucket_prefix,
                     'id'            => @id }
      @logger.info "Adding entry #{@id}."
      sdb.put_attributes @domain, @id, attributes
    end

    def encrypted?
      @secret != nil
    end

    def user
      ENV['USER']
    end

    def hostname
      Socket.gethostname
    end

    def sdb
      @sdb ||= AWS::SimpleDB.new :config => @config
    end

  end
end
