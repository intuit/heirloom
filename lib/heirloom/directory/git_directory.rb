require 'grit'

include Grit

module Heirloom

  class GitDirectory

    attr_accessor :path

    def initialize(args)
      self.path = args[:path]
    end

    def commit(sha = nil)
      repo = Repo.new path
      sha ? repo.commits(sha).first : repo.commits.first
    end

  end
end
