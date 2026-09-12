class FixBadeuceyPotRules < ActiveRecord::Migration[8.1]
  def up
    Variant.where("name ILIKE ?", "%Badeucey%").find_each do |variant|
      variant.hand_rules.find_by(pot_number: 1)&.update_columns(rule: "badeucey", ace_behavior: "high")
      variant.hand_rules.find_by(pot_number: 2)&.update_columns(rule: "deuce_to_seven_low", ace_behavior: "high")
    end
  end

  def down
    # The prior values were not canonical and are intentionally not restored.
  end
end
