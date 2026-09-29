class RenameBadeuceyHandRules < ActiveRecord::Migration[8.1]
  def up
    Variant.where(pot_1_hand_rule: "badeucey").update_all(pot_1_hand_rule: "badugi_high")
    Variant.where(pot_2_hand_rule: "badeucey").update_all(pot_2_hand_rule: "badugi_high")
  end

  def down
    Variant.where(pot_1_hand_rule: "badugi_high").update_all(pot_1_hand_rule: "badeucey")
    Variant.where(pot_2_hand_rule: "badugi_high").update_all(pot_2_hand_rule: "badeucey")
  end
end
