class AddApiKeyToAdmins < ActiveRecord::Migration[5.2]
  def change
    add_column :admins, :api_key, :varchar
  end
end
