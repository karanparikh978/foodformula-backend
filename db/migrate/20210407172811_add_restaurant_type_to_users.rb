class AddRestaurantTypeToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :restaurant_type, :string
  end
end
