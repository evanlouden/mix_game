class RemoveBugIsWildVariants < ActiveRecord::Migration[8.1]
  def up
    Variant.where("COALESCE(wild_cards, '') ILIKE '%Bug is wild%' OR COALESCE(special_mechanics, '') ILIKE '%Bug is wild%' OR COALESCE(source_notes, '') ILIKE '%Bug is wild%'").destroy_all
  end

  def down
    # Removed variants are intentionally not restored.
  end
end
