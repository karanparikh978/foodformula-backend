class AddImageAccessToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :image_access, :boolean
  end
end
