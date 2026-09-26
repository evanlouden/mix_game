class CorrectCincinnatiSequence < ActiveRecord::Migration[8.1]
  def up
    Variant.where(name: "Cincinnati").find_each do |variant|
      variant.sequence_steps.delete_all
      labels = ["4 DOWN", "BET", "COMMUNITY", "BET", "COMMUNITY", "BET", "COMMUNITY", "BET", "COMMUNITY", "BET"]
      labels.each_with_index do |label, index|
        if label == "BET"
          variant.sequence_steps.create!(position: index + 1, action_type: "betting")
        elsif label == "4 DOWN"
          variant.sequence_steps.create!(position: index + 1, action_type: "deal", card_scope: "individual", number_of_cards: 4, cards_down: 4, quantity_unit: "cards")
        else
          variant.sequence_steps.create!(position: index + 1, action_type: "deal", card_scope: "community", number_of_cards: 1, quantity_unit: "community cards")
        end
      end
    end
  end

  def down
    # Corrected sequence is retained on rollback.
  end
end
