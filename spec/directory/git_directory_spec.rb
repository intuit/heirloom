require 'spec_helper'

describe Heirloom do

  before do
    @repo_mock = double 'repo mock'
    @git_directory = Heirloom::GitDirectory.new :path => '/target/dir'
    Repo.should_receive(:new).with('/target/dir').and_return(@repo_mock)
    @commits_mock = double 'commits mock'
  end

  it "should read commit from the given path" do
    @repo_mock.should_receive(:commits).and_return(@commits_mock)
    @commits_mock.should_receive(:first).and_return('git_sha')
    @git_directory.commit.should == 'git_sha'
  end

  it "should read commit from the given path" do
    @repo_mock.should_receive(:commits).with('sha_i_want').
               and_return(@commits_mock)
    @commits_mock.should_receive(:first).and_return('git_sha')
    @git_directory.commit('sha_i_want').should == 'git_sha'
  end

  it "should return false if the commit given does not exist" do
    @repo_mock.should_receive(:commits).with('sha_that_dont_exist').
               and_return(@commits_mock)
    @commits_mock.should_receive(:first).and_return nil
    @git_directory.commit('sha_that_dont_exist').should be_false
  end

end
