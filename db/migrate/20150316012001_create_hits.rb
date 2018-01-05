class CreateHits < ActiveRecord::Migration[4.2]
  def change
    create_table :hits do |t|
      t.references :entry, index: true
      t.integer :runs
      t.date :hit_on

      t.timestamps null: false
    end
    add_foreign_key :hits, :entries
  end
end
