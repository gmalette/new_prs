module NewPrs
  module Actions
    class FindOrCreateUser
      def self.find_or_create_user(login:, graphql_id:, myself: nil)
        user = NewPrs::User
          .where(login: login, graphql_id: graphql_id)
          .first_or_create!

        return user if myself.nil?

        user.update(myself: myself)
        user
      end
    end
  end
end
