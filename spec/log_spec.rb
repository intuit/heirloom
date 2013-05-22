require 'spec_helper'

describe Heirloom::Log do

  class DummyClass
  end

  before do
    @dummy = DummyClass.new
    @dummy.extend(Heirloom::Log)
  end

  it "should have a log" do
    @dummy.log.should respond_to :info
  end

end
