module NewPrs
  module Actions
    class FetchUser
      Query = GithubClient.parse(<<~GRAPHQL)
        query($login: String!) {
          user(login: $login) {
            id
            login
          }
        }
      GRAPHQL

      private_constant :Query

      def self.fetch_user(login:)
        resp = GithubClient.query(Query, variables: { login: login })
        resp.data.user
      end
    end
  end
end
