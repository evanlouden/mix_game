class NormalizePotQualifiers < ActiveRecord::Migration[8.1]
  def up
    Variant.where(pot_1_qualifier: "8 or better").update_all(pot_1_qualifier: "eight")
    Variant.where(pot_2_qualifier: "8 or better").update_all(pot_2_qualifier: "eight")
    Variant.where(pot_1_qualifier: "Jacks or better").update_all(pot_1_qualifier: "jacks")
    Variant.where(pot_2_qualifier: "Jacks or better").update_all(pot_2_qualifier: "jacks")
  end

  def down
    Variant.where(pot_1_qualifier: "eight").update_all(pot_1_qualifier: "8 or better")
    Variant.where(pot_2_qualifier: "eight").update_all(pot_2_qualifier: "8 or better")
    Variant.where(pot_1_qualifier: "jacks").update_all(pot_1_qualifier: "Jacks or better")
    Variant.where(pot_2_qualifier: "jacks").update_all(pot_2_qualifier: "Jacks or better")
  end
end
