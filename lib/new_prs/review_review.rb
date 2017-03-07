class NewPrs::ReviewReview < NewPrs::Record
  belongs_to(:user)
  belongs_to(:pull_request)
end
