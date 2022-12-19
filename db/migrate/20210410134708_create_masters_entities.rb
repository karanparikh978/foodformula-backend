class CreateMastersEntities < ActiveRecord::Migration[5.2]
  def change
    create_table :masters_entities do |t|
      t.string :name
      t.string :status_id

      t.timestamps
    end
  end
end
