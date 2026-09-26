class CorrectPineappleDiscardSequence < ActiveRecord::Migration[8.1]
  def up
    Variant.where(name: ["Pineapple", "Pineapple 8"]).find_each do |variant|
      variant.sequence_steps.delete_all
      labels = ["3 DOWN", "BET", "DISCARD 1 CARD", "C C C", "BET", "C", "BET", "C", "BET"]
      labels.each_with_index do |label, index|
        position = index + 1
        attrs = case label
        when "3 DOWN"
          { action_type: "deal", card_scope: "individual", number_of_cards: 3, cards_down: 3, quantity_unit: "cards" }
        when "BET"
          { action_type: "betting" }
        when "DISCARD 1 CARD"
          { action_type: "discard", max_cards: 1 }
        else
          { action_type: "deal", card_scope: "community", number_of_cards: label.count("C"), quantity_unit: "community cards" }
        end
        variant.sequence_steps.create!(attrs.merge(position: position))
      end
    end
  end

  def down
    # Corrected sequence is retained on rollback.
  end
end
