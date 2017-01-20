class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string(:login, null: false)
      t.string(:graphql_id, null: false)
      t.timestamps(null: false)

      t.index(:graphql_id, unique: true)
    end
  end
end
