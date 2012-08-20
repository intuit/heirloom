require 'grit'

include Grit

module Heirloom

  class GitDirectory

    def initialize(args)
      @path = args[:path]
    end

    def commit(sha = nil)
      return false unless repo

      if sha
        commit = repo.commits(sha)
        commit ? commit.first : false
      else
        repo.commits.first
      end
    end

    private

    def repo
      Repo.new @path
    rescue Grit::InvalidGitRepositoryError
      false
    end

  end
end
