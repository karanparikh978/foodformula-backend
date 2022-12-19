class CreateEntityImages < ActiveRecord::Migration[5.2]
  def change
    create_table :entity_images do |t|
      t.integer :entity_type
      t.integer :entity_type_id
      t.string :url
      t.integer :status_id
      t.integer :status_id

      t.timestamps
    end
  end
end
