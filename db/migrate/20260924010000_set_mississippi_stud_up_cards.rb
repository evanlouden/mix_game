class SetMississippiStudUpCards < ActiveRecord::Migration[8.1]
  NAMES = ["Mississippi Stud", "Mississippi Stud 8"].freeze

  def up
    Variant.where(name: NAMES).find_each do |variant|
      variant.sequence_steps.find_by(position: 3, action_type: "deal", card_scope: "individual")&.update!(cards_down: nil, cards_up: 2)
      variant.sequence_steps.find_by(position: 5, action_type: "deal", card_scope: "individual")&.update!(cards_down: nil, cards_up: 1)
      variant.sequence_steps.find_by(position: 7, action_type: "deal", card_scope: "individual")&.update!(cards_down: nil, cards_up: 1)
    end
  end

  def down
    Variant.where(name: NAMES).find_each do |variant|
      [3, 5, 7].each do |position|
        variant.sequence_steps.find_by(position: position, action_type: "deal", card_scope: "individual")&.update!(cards_down: nil, cards_up: nil)
      end
    end
  end
end
