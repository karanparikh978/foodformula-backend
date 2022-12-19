class AddColorColumnsToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :color1, :varchar
    add_column :users, :color2, :varchar
    add_column :users, :color3, :varchar
  end
end
