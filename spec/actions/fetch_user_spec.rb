require "spec_helper"

describe NewPrs::Actions::FetchUser do
  describe ":fetch_user" do
    it "queries GithubClient for the login and returns the user" do
      user = double
      expect(NewPrs::GithubClient)
        .to(receive(:query))
        .and_return(double(data: double(user: user)))

      expect(described_class.fetch_user(login: "gmalette")).to eq(user)
    end
  end
end
