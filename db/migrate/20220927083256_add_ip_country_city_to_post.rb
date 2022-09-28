class AddIpCountryCityToPost < ActiveRecord::Migration[6.1]
  def change
    add_column :posts, :country, :string
    add_column :posts, :city, :string
  end
end
