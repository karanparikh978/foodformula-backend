class AddColumnsToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :api_key, :varchar
    add_column :users, :status_id, :integer
    add_column :users, :sign_in_count, :integer
    add_column :users, :last_sign_in_at, :timestamp
    add_column :users, :current_sign_in_at, :timestamp
  end
end
