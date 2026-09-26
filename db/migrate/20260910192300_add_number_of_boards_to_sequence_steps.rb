class AddNumberOfBoardsToSequenceSteps < ActiveRecord::Migration[8.1]
  def up
    add_column :sequence_steps, :number_of_boards, :integer
    execute "UPDATE sequence_steps SET action_type = 'deal' WHERE action_type = 'community'"
    SequenceStep.where(quantity_unit: "community cards").find_each do |step|
      boards = step.variant.name.to_s.match?(/\ADouble-Board/i) ? 2 : 1
      step.update_columns(action_type: "deal", card_scope: "community", number_of_boards: boards)
    end
  end

  def down
    remove_column :sequence_steps, :number_of_boards
  end
end
