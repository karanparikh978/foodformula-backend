class AddMenuKeyToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :menu_key, :string
  end
end
