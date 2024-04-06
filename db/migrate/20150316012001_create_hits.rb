# frozen_string_literal: true

class CreateHits < ActiveRecord::Migration[6.0]
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
