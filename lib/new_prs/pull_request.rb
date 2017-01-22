class NewPrs::PullRequest < NewPrs::Record
  belongs_to(:user)
  belongs_to(:repository)
end
