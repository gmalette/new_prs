class CreateRepositories < ActiveRecord::Migration[5.0]
  def change
    create_table :repositories do |t|
      t.string(:owner, null: false)
      t.string(:name, null: false)
      t.string(:last_pull_request_cursor, null: true)
      t.timestamps(null: false)
    end
  end
end
