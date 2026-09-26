class CorrectShowmaha8Sequence < ActiveRecord::Migration[8.1]
  def up
    Variant.where(name: "Showmaha 8").find_each do |variant|
      next unless variant.sequence_steps.count == 5
      next unless variant.sequence_steps.where(position: 1, action_type: "deal", card_scope: "individual").exists?
      next if variant.sequence_steps.where(action_type: "reveal").exists?

      variant.sequence_steps.where("position > 2").delete_all
      [
        { position: 3, action_type: "deal", card_scope: "community", cards_up: 3 },
        { position: 4, action_type: "reveal", card_scope: "individual", cards_up: 2 },
        { position: 5, action_type: "betting" },
        { position: 6, action_type: "deal", card_scope: "community", cards_up: 1 },
        { position: 7, action_type: "betting" },
        { position: 8, action_type: "deal", card_scope: "community", cards_up: 1 },
        { position: 9, action_type: "betting" }
      ].each { |attributes| variant.sequence_steps.create!(attributes) }
    end
  end

  def down
    Variant.where(name: "Showmaha 8").find_each do |variant|
      next unless variant.sequence_steps.where(action_type: "reveal").exists?

      variant.sequence_steps.where("position > 2").delete_all
      3.upto(5) { |position| variant.sequence_steps.create!(position: position, action_type: "betting") }
    end
  end
end
