require 'spec_helper'

describe Heirloom do

  it "should have a global logger" do
    expect {
      Heirloom.log
    }.not_to raise_error
  end

  it "should have a global config" do
    expect {
      Heirloom.config
    }.not_to raise_error
  end

end
