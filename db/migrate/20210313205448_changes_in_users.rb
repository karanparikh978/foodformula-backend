class ChangesInUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :username, :varchar
    add_column :users, :currency, :varchar
    add_column :users, :start_date, :timestamp
    add_column :users, :end_date, :timestamp
    add_column :users, :enable_access_state, :integer
  end
end
