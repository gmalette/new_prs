class CreatePullRequests < ActiveRecord::Migration[5.0]
  def change
    create_table :pull_requests do |t|
      t.references(:user, null: false)
      t.references(:repository, null: false)
      t.string(:title, null: false)
      t.boolean(:seen, null: false)
      t.string(:graphql_id, null: false)
      t.integer(:number, null: false)
      t.string(:state, null: false)
      t.string(:path, null: false)
      t.datetime(:github_created_at, null: false)
      t.datetime(:github_updated_at, null: false)
      t.timestamps(null: false)

      t.index(:graphql_id, unique: true)
    end
  end
end
