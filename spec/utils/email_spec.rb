require 'spec_helper'

describe Heirloom::Utils::Email do
  before do
    @object = Object.new
    @object.extend Heirloom::Utils::Email
  end

  it "should return that the account is a valid email " do
    account = 'good@good.com'
    @object.valid_email?(account).should be_true
  end

  it "should return that the account is a valid email " do
    account = 'bad@bad'
    @object.valid_email?(account).should be_false
  end

  it "should return that the account is a valid email " do
    account = '123456789_123456'
    @object.valid_email?(account).should be_false
  end

end
