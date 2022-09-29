class CreateGroups < ActiveRecord::Migration[6.1]
  def change
    create_table :groups do |t|
      t.string :name
      t.string :description
      t.string :banner
      t.integer :genre
      t.belongs_to :user
      t.timestamps
    end
  end
end