require 'grit'

include Grit

module Heirloom

  class GitDirectory

    attr_accessor :path

    def initialize(args)
      self.path = args[:path]
    end

    def commit(sha = nil)
      r = Repo.new path
      sha ? r.commits(sha).first : r.commits.first
    end

  end
end
