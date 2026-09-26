class CorrectBillabongSequence < ActiveRecord::Migration[8.1]
  def up
    Variant.where(name: "Billabong").find_each do |variant|
      next unless variant.sequence_steps.where(position: 1, action_type: "deal", card_scope: "individual", cards_down: 2, cards_up: 1).exists?

      variant.sequence_steps.where("position > 8").delete_all
    end
  end

  def down
    Variant.where(name: "Billabong").find_each do |variant|
      next if variant.sequence_steps.where(position: 9).exists?

      variant.sequence_steps.create!(position: 9, action_type: "deal", card_scope: "individual", cards_down: 1)
      variant.sequence_steps.create!(position: 10, action_type: "betting")
    end
  end
end
