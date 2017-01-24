module NewPrs
  module Actions
    class SeedSelf
      def self.seed_self
        user = NewPrs::Actions::FetchUser.fetch_self
        NewPrs::User.where(login: user.login, graphql_id: user.id, myself: true).first_or_create!
      end
    end
  end
end
