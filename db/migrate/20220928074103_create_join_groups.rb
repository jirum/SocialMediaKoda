class CreateJoinGroups < ActiveRecord::Migration[6.1]
  def change
    create_table :join_groups do |t|
      t.string :state
      t.boolean :is_owner, default: false
      t.integer :role
      t.belongs_to :user
      t.belongs_to :group
      t.timestamps
    end
  end
end
