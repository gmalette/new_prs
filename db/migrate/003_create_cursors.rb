class CreateCursors < ActiveRecord::Migration
  def change
    create_table :cursors do |t|
      t.string(:resource, null: false)
      t.string(:graphql_id, null: false)

      t.index(:resource, unique: true)
    end
  end
end
