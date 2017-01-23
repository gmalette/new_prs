class NewPrs::User < NewPrs::Record
  has_many(:pull_requests)
end
