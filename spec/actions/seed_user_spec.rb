require "spec_helper"

describe NewPrs::Actions::SeedUser do
  describe ":seed_user" do
    it "creates a user" do
      user = NewPrs::Actions::FetchUser::UserFragment.new(
        "login" => "gmalette",
        "id" => "1234",
      )
      expect(NewPrs::Actions::FetchUser)
        .to(receive(:fetch_user).with(login: "gmalette"))
        .and_return(user)

      expect{ described_class.seed_user(login: "gmalette") }.to change{ NewPrs::User.count }.by(1)
    end

    it "doesn't create duplicate users" do
      NewPrs::User.create(login: "gmalette", graphql_id: "abcd")

      user = NewPrs::Actions::FetchUser::UserFragment.new(
        "login" => "gmalette",
        "id" => "abcd",
      )

      expect(NewPrs::Actions::FetchUser)
        .to(receive(:fetch_user).with(login: "gmalette"))
        .and_return(user)

      expect{ described_class.seed_user(login: "gmalette") }.not_to change{ NewPrs::User.count }
    end

    it "raises if the user is nil" do
      expect(NewPrs::Actions::FetchUser)
        .to(receive(:fetch_user).with(login: "gmalette"))
        .and_return(nil)

      expect{ described_class.seed_user(login: "gmalette") }.to raise_error("User not found: gmalette")
    end
  end
end
