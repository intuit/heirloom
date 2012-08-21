require 'spec_helper'

describe Heirloom do

  describe 'commit' do
    before do
      @repo_mock     = double 'repo mock'
      @git_directory = Heirloom::GitDirectory.new :path => '/target/dir'
    end
    
    context "when dir is git repo" do
      before do
        Repo.should_receive(:new).with('/target/dir').exactly(2).times.
             and_return(@repo_mock)
      end

      it "should return the first commit from the given repo" do
        @repo_mock.stub(:commits).and_return(['git_sha', 'other_sha'])
        @git_directory.commit.should == 'git_sha'
      end

      it "should read commit from the given path" do
        @repo_mock.should_receive(:commits).
                   with('sha_i_want').
                   and_return(['sha_i_want', 'other_sha'])
        @git_directory.commit('sha_i_want').should == 'sha_i_want'
      end

      it "should return false if the commit given does not exist" do
        @repo_mock.should_receive(:commits).
                   with('sha_that_dont_exist').
                   and_return(nil)
        @git_directory.commit('sha_that_dont_exist').should be_false
      end
    end

    context "when dir is not git repo" do
      it "should return false if the directory is not a git repo" do
        Repo.should_receive(:new).with('/target/dir').
             and_raise Grit::InvalidGitRepositoryError
        @git_directory.commit.should be_false
      end
    end

  end

end
