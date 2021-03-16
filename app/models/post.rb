class Post < ApplicationRecord
  attachment :image
  belongs_to :user
  after_create{ REDIS.zincrby "posts", 1, self.id}
  
  with_options presence: true do
    validates :title
    validates :body
    validates :image
  end
end
