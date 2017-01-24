module NewPrs
  module Actions
    class SeedUser
      def self.seed_user(login:)
        user = NewPrs::Actions::FetchUser.fetch_user(login: login)
        raise "User not found: #{login}" if user.nil?
        NewPrs::User.where(login: login, graphql_id: user.id, myself: false).first_or_create!
      end
    end
  end
end
