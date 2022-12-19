class ChangeDataTypeOfMobileNo < ActiveRecord::Migration[5.2]
  def change
    change_column :users, :mobile_no, :bigint
  end
end
