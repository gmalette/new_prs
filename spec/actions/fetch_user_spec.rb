require "spec_helper"

describe NewPrs::Actions::FetchUser do
  describe ":fetch_user" do
    it "queries GithubClient for the login and returns the user" do
      user = { "login" => "gmalette", "id" => "abcd" }
      expect(NewPrs::GithubClient)
        .to(receive(:query))
        .and_return(double(data: double(user: user)))

      fetched_user = described_class.fetch_user(login: "gmalette")
      expect(fetched_user.login).to eq("gmalette")
      expect(fetched_user.id).to eq("abcd")
    end
  end
end
