class SetBillabongTwoCardFlop < ActiveRecord::Migration[8.1]
  def up
    Variant.where(name: "Billabong").find_each do |variant|
      variant.sequence_steps.find_by(position: 3, action_type: "deal", card_scope: "community")&.update!(cards_up: 2)
    end
  end

  def down
    Variant.where(name: "Billabong").find_each do |variant|
      variant.sequence_steps.find_by(position: 3, action_type: "deal", card_scope: "community")&.update!(cards_up: 1)
    end
  end
end
