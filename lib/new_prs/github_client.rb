module NewPrs
  schema_cache_path = Pathname.new("./tmp/github_graphql_schema.json").expand_path

  adapter = GraphQL::Client::HTTP.new("https://api.github.com/graphql") do
    def headers(context)
      unless token = ENV["GITHUB_ACCESS_TOKEN"]
        fail "Missing GitHub access token"
      end

      {
        "Authorization" => "Bearer #{token}"
      }
    end
  end

  schema =
    if File.exist?(schema_cache_path)
      schema_cache_path.to_s
    else
      schema = GraphQL::Client.load_schema(adapter)
      FileUtils.mkdir_p(schema_cache_path.dirname)
      GraphQL::Client.dump_schema(adapter, schema_cache_path.to_s)
      schema
    end

  GithubClient = GraphQL::Client.new(
    schema: schema,
    execute: adapter,
  )
end
