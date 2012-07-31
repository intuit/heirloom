require 'grit'

include Grit

module Heirloom

  class GitDirectory

    def initialize(args)
      @path = args[:path]
    end

    def commit(sha = nil)
      repo = Repo.new @path
      if sha 
        commit = repo.commits(sha)
        commit ? commit.first : false
      else
        repo.commits.first
      end
    end

  end
end
