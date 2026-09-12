class FixDrawmaha177OmahaConstruction < ActiveRecord::Migration[8.1]
  def up
    variant = Variant.find_by(source_id: "V177") || Variant.find_by(id: 177)
    return unless variant

    rule = variant.hand_rules.where(pot_number: 2).first || variant.hand_rules.where("notes ILIKE ?", "%Omaha%").first
    rule&.update_columns(rule: "standard_high", hole_cards_required: 2, community_cards_required: 3)
  end

  def down
    # The Omaha construction is intentionally retained.
  end
end
