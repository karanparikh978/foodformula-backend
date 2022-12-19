class CreateUserEntities < ActiveRecord::Migration[5.2]
  def change
    create_table :user_entities do |t|
      t.integer :user_id
      t.integer :entity_id

      t.timestamps
    end
  end
end
