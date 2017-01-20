require "spec_helper"

describe NewPrs do
  it "has a version number" do
    expect(NewPrs::VERSION).not_to be nil
  end
end
