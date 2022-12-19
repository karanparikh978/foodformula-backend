class AddStatusIdToAdmins < ActiveRecord::Migration[5.2]
  def change
    add_column :admins, :status_id, :integer
  end
end
