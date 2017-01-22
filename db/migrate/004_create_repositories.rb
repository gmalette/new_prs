class CreateRepositories < ActiveRecord::Migration
  def change
    create_table :repositories do |t|
      t.string(:owner, null: false)
      t.string(:name, null: false)
    end
  end
end
