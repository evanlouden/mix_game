class AddFusionTurnAndRiverDownCards < ActiveRecord::Migration[8.1]
  def up
    Variant.where(name: "Fusion").find_each do |variant|
      next unless variant.sequence_steps.where(action_type: "deal", card_scope: "community").count >= 2
      next if variant.sequence_steps.where(position: 5, action_type: "deal", card_scope: "individual").exists?

      position_map = { 5 => 6, 6 => 7, 7 => 9, 8 => 10 }
      variant.sequence_steps.where(position: position_map.keys).each do |step|
        step.update_columns(position: step.position + 1000)
      end
      variant.sequence_steps.where("position >= 1005").each do |step|
        step.update_columns(position: position_map.fetch(step.position - 1000))
      end

      variant.sequence_steps.create!(position: 5, action_type: "deal", card_scope: "individual", cards_down: 1)
      variant.sequence_steps.create!(position: 8, action_type: "deal", card_scope: "individual", cards_down: 1)
    end
  end

  def down
    Variant.where(name: "Fusion").find_each do |variant|
      down_cards = variant.sequence_steps.where(position: [5, 8], action_type: "deal", card_scope: "individual", cards_down: 1)
      next unless down_cards.count == 2

      down_cards.destroy_all
      position_map = { 6 => 5, 7 => 6, 9 => 7, 10 => 8 }
      variant.sequence_steps.where(position: position_map.keys).each do |step|
        step.update_columns(position: step.position + 1000)
      end
      variant.sequence_steps.where("position >= 1006").each do |step|
        step.update_columns(position: position_map.fetch(step.position - 1000))
      end
    end
  end
end
