class CorrectStudahaHandRules < ActiveRecord::Migration[8.1]
  def up
    rule = HandRule.find_by(variant_id: 83, pot_number: 2)
    return unless rule

    rule.update_columns(
      rule: "high_omaha",
      direction: "high",
      hand_size: 5,
      hole_cards_required: 2,
      community_cards_required: 3,
      ace_behavior: "either"
    )
  end

  def down
    rule = HandRule.find_by(variant_id: 83, pot_number: 2)
    return unless rule

    rule.update_columns(
      rule: "standard_high",
      direction: "low",
      hole_cards_required: nil,
      community_cards_required: 3,
      ace_behavior: "either"
    )
  end
end
