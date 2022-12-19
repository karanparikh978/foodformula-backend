class AddMapLinkToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :map_link, :string
  end
end
