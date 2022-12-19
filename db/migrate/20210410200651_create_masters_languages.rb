class CreateMastersLanguages < ActiveRecord::Migration[5.2]
  def change
    create_table :masters_languages do |t|
      t.string :name
      t.integer :status_id

      t.timestamps
    end
  end
end
