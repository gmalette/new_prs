class NewPrs::Repository < NewPrs::Record
  has_many(:pull_requests)
end
