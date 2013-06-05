require 'spec_helper'
require 'heirloom/cli'

describe Heirloom::CLI do
  context "commands" do

    it "should generate a list of subcommands" do
      Heirloom::CLI.commands.size.should > 0
    end
    
  end
end
