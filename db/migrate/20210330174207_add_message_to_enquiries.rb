class AddMessageToEnquiries < ActiveRecord::Migration[5.2]
  def change
    add_column :enquiries, :message, :string
  end
end
