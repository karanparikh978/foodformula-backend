class AddOtherColumnsToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :name, :varchar
    add_column :users, :mobile_no, :integer
  end
end
