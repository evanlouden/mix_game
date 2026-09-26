class SetMississippiStudSecondStreetCards < ActiveRecord::Migration[8.1]
  def up
    Variant.where(name: "Mississippi Stud").find_each do |variant|
      variant.sequence_steps.find_by(position: 3, action_type: "deal", card_scope: "individual")&.update!(cards_down: nil, cards_up: 2)
    end
  end

  def down
    Variant.where(name: "Mississippi Stud").find_each do |variant|
      variant.sequence_steps.find_by(position: 3, action_type: "deal", card_scope: "individual")&.update!(cards_down: nil, cards_up: nil)
    end
  end
end
