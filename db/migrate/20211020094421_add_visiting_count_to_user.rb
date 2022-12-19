class AddVisitingCountToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :visitng_count, :integer
  end
end
