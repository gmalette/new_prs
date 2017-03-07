module NewPrs
  module GraphQLThrottle
    NoData = Class.new(StandardError)

    def self.examine(response)
      if response.data.nil?
        message =
          if response.errors.any?
            if response.errors.messages["data"].grep(/403/).any?
              error_headers = GithubClient.execute.last_response.each_header.to_h
              time_to_throttle = error_headers["x-ratelimit-reset"].to_i - Time.now.to_i
              "Throttled. Try atain in #{time_to_throttle} seconds"
            else
              "Aborting query\n  #{response.errors.messages.inspect}"
            end
          else
            "Aborting query to fetch new pull requests, unknown reason"
          end

        raise(NoData, message)
      end
    end
  end
end
