class AddBugToVariants < ActiveRecord::Migration[8.1]
  def up
    add_column :variants, :bug, :boolean, null: false, default: false
    execute <<~SQL
      UPDATE variants
      SET bug = TRUE
      WHERE COALESCE(wild_cards, '') ILIKE '%bug%'
         OR COALESCE(deck_modification, '') ILIKE '%bug%'
         OR COALESCE(special_mechanics, '') ILIKE '%bug%'
         OR COALESCE(source_notes, '') ILIKE '%bug%'
    SQL
  end

  def down
    remove_column :variants, :bug
  end
end
