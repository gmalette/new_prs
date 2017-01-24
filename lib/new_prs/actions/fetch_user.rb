module NewPrs
  module Actions
    class FetchUser
      UserQuery = GithubClient.parse(<<~GRAPHQL)
        query($login: String!) {
          user(login: $login) {
            id
            login
          }
        }
      GRAPHQL

      SelfQuery = GithubClient.parse(<<~GRAPHQL)
        query {
          viewer{
            id
            login
          }
        }
      GRAPHQL

      private_constant :UserQuery, :SelfQuery

      def self.fetch_user(login:)
        response = GithubClient.query(UserQuery, variables: { login: login })
        response.data.user
      end

      def self.fetch_self
        response = GithubClient.query(SelfQuery)
        response.data.viewer
      end
    end
  end
end
