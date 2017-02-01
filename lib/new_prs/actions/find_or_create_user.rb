module NewPrs
  module Actions
    class FindOrCreateUser
      def self.find_or_create_user(graphql_id:, **attrs)
        user = NewPrs::User
          .where(graphql_id: graphql_id)
          .first_or_initialize

        user.update!(**attrs)

        user
      end
    end
  end
end
