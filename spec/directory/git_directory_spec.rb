require 'spec_helper'

describe Heirloom do

    before do
      @git_directory = Heirloom::GitDirectory.new :path => '/target/dir'
    end

    it "should read commit from the given path" do
      repo_mock = double 'repo mock'
      Repo.should_receive(:new).with('/target/dir').and_return(repo_mock)
      commits_mock = double 'commits mock'
      repo_mock.should_receive(:commits).and_return(commits_mock)
      commits_mock.should_receive(:first).and_return('git_sha')
      @git_directory.commit.should == 'git_sha'
    end

    it "should read commit from the given path" do
      repo_mock = double 'repo mock'
      Repo.should_receive(:new).with('/target/dir').and_return(repo_mock)
      commits_mock = double 'commits mock'
      repo_mock.should_receive(:commits).with('sha_i_want').
                and_return(commits_mock)
      commits_mock.should_receive(:first).and_return('git_sha')
      @git_directory.commit 'sha_i_want'
    end

end
