require 'spec_helper'

describe Heirloom do

  it "should return ENV value if passed the name" do
    set_env_var("HOME", "~")
    env = Heirloom::Env.new
    expect(env.load 'HOME').to eq '~'
  end

  it "should return nil if the ENV name does not exist" do
    env = Heirloom::Env.new
    expect(env.load 'SOME_RANDOM_MISSING_VALUE').to eq nil
  end

end
