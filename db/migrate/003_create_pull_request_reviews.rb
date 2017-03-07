class CreatePullRequestReviews < ActiveRecord::Migration[5.0]
  def change
    create_table :pull_request_reviews do |t|
      t.references(:pull_request, null: false)
      t.references(:user, null: false)
      t.string(:state, null: false)
      t.string(:graphql_id, null: false)
      t.integer(:comment_count, null: false, default: 0)
      t.timestamps(null: false)

      t.index(:graphql_id, unique: true)
    end
  end
end
