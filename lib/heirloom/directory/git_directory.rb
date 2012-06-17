require 'grit'

include Grit

module Heirloom

  class GitDirectory

    def initialize(args)
      @directory = args[:directory]
      @logger = args[:logger]
    end

    def commit(sha = nil)
      r = Repo.new @directory
      sha ? r.commits(sha).first : r.commits.first
    end

  end
end
