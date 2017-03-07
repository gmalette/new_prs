class NewPrs::PullRequest < NewPrs::Record
  belongs_to(:user)
  belongs_to(:repository)

  has_many(:pull_request_reviews)

  def url
    ["https://github.com", path].join("/")
  end
end
