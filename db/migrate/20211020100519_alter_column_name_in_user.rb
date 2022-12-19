class AlterColumnNameInUser < ActiveRecord::Migration[5.2]
  def change
    rename_column :users, :visitng_count, :visiting_count
  end
end
