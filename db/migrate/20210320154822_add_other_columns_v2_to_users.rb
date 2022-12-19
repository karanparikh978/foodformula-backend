class AddOtherColumnsV2ToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :website, :varchar
    add_column :users, :manager_name, :varchar
  end
end
