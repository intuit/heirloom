require 'spec_helper'

describe GlobalLog do

  class DummyClass
  end

  before do
    @dummy = DummyClass.new
    @dummy.extend(GlobalLog)
  end

  it "should have a log" do
    @dummy.log.should respond_to :info
  end

end
