class MarkFlopTurnRiverBombPots < ActiveRecord::Migration[8.1]
  class VariantRecord < ActiveRecord::Base
    self.table_name = "variants"
  end

  class SequenceStepRecord < ActiveRecord::Base
    self.table_name = "sequence_steps"
  end

  def up
    community_deals = SequenceStepRecord
      .where(action_type: "deal", card_scope: "community")
      .order(:variant_id, :position)
      .to_a
      .group_by(&:variant_id)

    flop_turn_river_ids = community_deals.filter_map do |variant_id, steps|
      variant_id if steps.map(&:cards_up) == [3, 1, 1]
    end

    eligible_ids = VariantRecord
      .where(id: flop_turn_river_ids, pot_2_hand_rule: [nil, ""])
      .pluck(:id)

    VariantRecord.update_all(bomb_pot: false)
    VariantRecord.where(id: eligible_ids).update_all(bomb_pot: true)
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "Bomb Pot eligibility is data-derived and cannot be safely restored"
  end
end
