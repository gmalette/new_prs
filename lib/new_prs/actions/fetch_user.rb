module NewPrs
  module Actions
    class FetchUser
      UserFragment = GithubClient.parse(<<~GRAPHQL)
        fragment on User {
          id
          login
        }
      GRAPHQL

      UserQuery = GithubClient.parse(<<~GRAPHQL)
        query($login: String!) {
          user(login: $login) {
            ...NewPrs::Actions::FetchUser::UserFragment
          }
        }
      GRAPHQL

      SelfQuery = GithubClient.parse(<<~GRAPHQL)
        query {
          viewer {
            ...NewPrs::Actions::FetchUser::UserFragment
          }
        }
      GRAPHQL

      private_constant :UserQuery, :SelfQuery

      def self.fetch_user(login:)
        response = GithubClient.query(UserQuery, variables: { login: login })
        UserFragment.new(response.data.user)
      end

      def self.fetch_self
        response = GithubClient.query(SelfQuery)
        UserFragment.new(response.data.viewer)
      end
    end
  end
end
