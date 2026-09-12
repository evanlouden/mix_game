class NormalizeHighQualifierMechanics < ActiveRecord::Migration[8.1]
  def up
    Variant.where(source_id: %w[V006 V090]).update_all(special_mechanics: "High qualifier: 99 or better (CAZ) or 66 or better (LV variant).")
    Variant.where(source_id: "V101").update_all(special_mechanics: "Jacks or better to open; trips to win.")
    Variant.where(source_id: "V104").update_all(special_mechanics: "Jacks or better to open; otherwise California Lowball (A-5).")

    Variant.where(source_id: %w[V006 V090]).find_each do |variant|
      variant.hand_rules.find_by(pot_number: 2)&.update_columns(rule: "ace_to_five_low", qualifier: "8 or better", ace_behavior: "low")
    end
    Variant.find_by(source_id: "V101")&.hand_rules&.find_by(pot_number: 1)&.update_columns(qualifier: "Jacks or better")
    Variant.find_by(source_id: "V104")&.hand_rules&.find_by(pot_number: 1)&.update_columns(qualifier: "Jacks or better")
  end

  def down
    # These normalized mechanics are retained on rollback.
  end
end
