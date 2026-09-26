class MaterializeDramahaSequenceSteps < ActiveRecord::Migration[8.1]
  LABELS = ["5 DOWN", "BET", "C C C", "BET", "DRAW", "C", "BET", "C", "BET"].freeze

  def up
    Variant.where("name ILIKE '%Dramaha%'").find_each do |variant|
      variant.sequence_steps.delete_all
      LABELS.each_with_index do |label, index|
        type = label == "BET" ? "betting" : label == "DRAW" ? "draw" : label.start_with?("C") ? "deal" : label.include?("DOWN") ? "deal" : "special"
        quantity = label == "5 DOWN" ? 5 : label == "C C C" ? 3 : label == "C" ? 1 : nil
        unit = label.include?("DOWN") ? "cards" : label.start_with?("C") ? "community cards" : nil
        variant.sequence_steps.create!(position: index + 1, action_type: type, number_of_cards: quantity, quantity_unit: unit)
      end
    end
  end

  def down
    # The materialized sequence is retained on rollback.
  end
end
