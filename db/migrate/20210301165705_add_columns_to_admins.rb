class AddColumnsToAdmins < ActiveRecord::Migration[5.2]
  def change
    add_column :admins, :sign_in_count, :integer
    add_column :admins, :last_sign_in_at, :timestamp
    add_column :admins, :current_sign_in_at, :timestamp
  end
end
