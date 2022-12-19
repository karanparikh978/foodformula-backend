class AddQrCodeCategoryToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :qr_code_category, :varchar
  end
end
