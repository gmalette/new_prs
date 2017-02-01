class NewPrs::PullRequestReview < NewPrs::Record
  belongs_to(:user)
  belongs_to(:pull_request)
end
