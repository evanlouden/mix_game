class AddBettingOptionsToVariants < ActiveRecord::Migration[8.1]
  def up
    add_column :variants, :no_limit, :boolean, null: false, default: false
    add_column :variants, :pot_limit, :boolean, null: false, default: false
    add_column :variants, :fixed_limit, :boolean, null: false, default: false

    execute <<~SQL
      UPDATE variants
      SET no_limit = betting_format = 'no_limit' OR (betting_format IS NULL AND COALESCE(betting_structure, '') NOT ILIKE '%Fixed-Limit%' AND COALESCE(betting_structure, '') NOT ILIKE '%Pot-Limit%'),
          pot_limit = betting_format = 'pot_limit' OR betting_structure ILIKE '%Pot-Limit%',
          fixed_limit = betting_format = 'fixed_limt' OR betting_structure ILIKE '%Fixed-Limit%'
    SQL
  end

  def down
    remove_column :variants, :no_limit
    remove_column :variants, :pot_limit
    remove_column :variants, :fixed_limit
  end
end
