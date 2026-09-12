class CreateSequenceSteps < ActiveRecord::Migration[8.1]
  def change
    create_table :sequence_steps do |t|
      t.references :variant, null: false, foreign_key: true
      t.integer :position, null: false
      t.string :action_type, null: false
      t.string :label, null: false
      t.integer :quantity
      t.string :quantity_unit
      t.text :details
      t.string :source_pages
      t.jsonb :metadata, default: {}, null: false
      t.timestamps
    end
    add_index :sequence_steps, %i[variant_id position], unique: true
    add_index :sequence_steps, :action_type
  end
end
