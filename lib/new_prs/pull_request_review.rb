class NewPrs::PullRequestReview < NewPrs::Record
  belongs_to(:user)
  belongs_to(:repository)
end
