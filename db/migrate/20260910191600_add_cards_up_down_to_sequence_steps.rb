class AddCardsUpDownToSequenceSteps < ActiveRecord::Migration[8.1]
  def up
    add_column :sequence_steps, :cards_down, :integer
    add_column :sequence_steps, :cards_up, :integer

    SequenceStep.find_each do |step|
      text = step.label.to_s.upcase
      down = text[/([0-9]+)\s+DOWN/, 1]&.to_i
      up = text[/([0-9]+)\s+UP/, 1]&.to_i
      if down || up
        step.update_columns(action_type: "deal", cards_down: down.presence, cards_up: up.presence)
      elsif step.action_type == "deal" && step.quantity_unit == "cards" && step.number_of_cards.present?
        step.update_columns(cards_down: step.number_of_cards)
      end
    end
  end

  def down
    remove_column :sequence_steps, :cards_up
    remove_column :sequence_steps, :cards_down
  end
end
