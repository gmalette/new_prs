require "spec_helper"

describe NewPrs::Actions::SeedUser do
  describe ":seed_user" do
    it "creates a user" do
      expect(NewPrs::Actions::FetchUser)
        .to(receive(:fetch_user).with(login: "gmalette"))
        .and_return(double(id: "abcd"))

      expect{ described_class.seed_user(login: "gmalette") }.to change{ NewPrs::User.count }.by(1)
    end

    it "doesn't create duplicate users" do
      NewPrs::User.create(login: "gmalette", graphql_id: "abcd")

      expect(NewPrs::Actions::FetchUser)
        .to(receive(:fetch_user).with(login: "gmalette"))
        .and_return(double(id: "abcd"))

      expect{ described_class.seed_user(login: "gmalette") }.not_to change{ NewPrs::User.count }
    end
  end
end