class ConsolidateDoubleBoardOmaha < ActiveRecord::Migration[8.1]
  class VariantRecord < ActiveRecord::Base
    self.table_name = "variants"
  end

  class SequenceStepRecord < ActiveRecord::Base
    self.table_name = "sequence_steps"
  end

  def up
    base_variant = VariantRecord.find_by(id: 37, name: "Omaha") || VariantRecord.find_by(name: "Omaha")
    double_board_variant = VariantRecord.find_by(id: 51, name: "Double-Board Omaha") || VariantRecord.find_by(name: "Double-Board Omaha")

    if base_variant
      modifiers = JSON.parse(base_variant.modifiers.presence || "[]")
      base_variant.update_columns(modifiers: (modifiers | ["double_board"]).to_json)
    end

    return unless double_board_variant

    SequenceStepRecord.where(variant_id: double_board_variant.id).delete_all
    double_board_variant.delete
  end

  def down
    # The standalone variant is intentionally not recreated during rollback.
  end
end
