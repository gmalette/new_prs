class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string(:login, null: false)
      t.string(:graphql_id, null: false)
      t.boolean(:myself, null: false, default: false)
      t.boolean(:watched, null: false, default: false)
      t.timestamps(null: false)

      t.index(:graphql_id, unique: true)
    end
  end
end
