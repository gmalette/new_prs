class CreateReviewReviews < ActiveRecord::Migration[5.0]
  def change
    create_table :review_reviews do |t|
      t.references(:pull_request, null: false)
      t.references(:user, null: false)
      t.integer(:score, null: false)
      t.string(:comment)
      t.timestamps(null: false)

      t.index([:pull_request_id, :user_id], unique: true)
    end
  end
end
