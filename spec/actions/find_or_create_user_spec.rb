require "spec_helper"

describe NewPrs::Actions::FindOrCreateUser do
  describe "find_or_create_user" do
    it "creates a user and sets myself to false by default" do
      expect {
        described_class.find_or_create_user(
          login: "gmalette",
          graphql_id: "1234",
        )
      }.to(change { NewPrs::User.count }.by(1))
      user = NewPrs::User.last
      expect(user.login).to eq("gmalette")
      expect(user.graphql_id).to eq("1234")
      expect(user.myself).to eq(false)
    end

    it "creates self user" do
      expect {
        described_class.find_or_create_user(
          login: "gmalette",
          graphql_id: "1234",
          myself: true,
        )
      }.to(change { NewPrs::User.count }.by(1))
      user = NewPrs::User.last
      expect(user.myself).to eq(true)
    end

    it "updates a user to become self" do
      user = create(:user, myself: false)
      found_user = nil
      expect {
        found_user = described_class.find_or_create_user(
          login: user.login,
          graphql_id: user.graphql_id,
          myself: true,
        )
      }.not_to(change { NewPrs::User.count })

      expect(user).to(eq(found_user))
    end

    it "finds existing users" do
      user = create(:user, myself: true)
      found_user = described_class.find_or_create_user(
        login: user.login,
        graphql_id: user.graphql_id,
      )

      expect(found_user).to(eq(user))
      expect(found_user.myself).to(be(true))
    end
  end
end
