class AddCourchevelFirstCommunityCard < ActiveRecord::Migration[8.1]
  COURCHEVEL_NAMES = ["Courchevel", "Courchevel 8"].freeze

  def up
    Variant.where(name: COURCHEVEL_NAMES).find_each do |variant|
      next if variant.sequence_steps.where(position: 2, action_type: "deal", card_scope: "community").exists?

      variant.sequence_steps.where("position >= 2").update_all("position = position + 1000")
      variant.sequence_steps.where("position >= 1002").update_all("position = position - 999")
      variant.sequence_steps.create!(position: 2, action_type: "deal", card_scope: "community", cards_up: 1)
    end
  end

  def down
    Variant.where(name: COURCHEVEL_NAMES).find_each do |variant|
      first_community_card = variant.sequence_steps.find_by(position: 2, action_type: "deal", card_scope: "community", cards_up: 1)
      next unless first_community_card

      first_community_card.destroy!
      variant.sequence_steps.where("position > 2").update_all("position = position - 1")
    end
  end
end
