module NewPrs
  module Actions
    class SeedUser
      def self.seed_user(login:)
        query = NewPrs::Actions::FetchUser.fetch_user(login: login)
        NewPrs::User.where(login: login, graphql_id: query.id).first_or_create!
      end
    end
  end
end
