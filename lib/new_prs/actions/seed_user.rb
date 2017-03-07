module NewPrs
  module Actions
    class SeedUser
      def self.seed_user(login:, **args)
        user = NewPrs::Actions::FetchUser.fetch_user(login: login)
        raise "User not found: #{login}" if user.nil?
        NewPrs::Actions::FindOrCreateUser.find_or_create_user(
          login: login,
          graphql_id: user.id,
          myself: false,
          **args,
        )
      end
    end
  end
end
