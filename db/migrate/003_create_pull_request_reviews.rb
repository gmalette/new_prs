class CreatePullRequestReviews < ActiveRecord::Migration
  def change
    create_table :pull_request_reviews do |t|
      t.references(:pull_request, null: false)
      t.references(:user, null: false)
      t.string(:state, null: false)
      t.integer(:score, null: false)
      t.string(:comment, null: false)
      t.timestamps(null: false)
    end
  end
end
