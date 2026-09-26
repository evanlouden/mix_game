class RemoveMississippiStudFinalDownCard < ActiveRecord::Migration[8.1]
  NAMES = ["Mississippi Stud", "Mississippi Stud 8"].freeze

  def up
    Variant.where(name: NAMES).find_each do |variant|
      variant.sequence_steps.where(position: 9, action_type: "deal", card_scope: "individual", cards_down: 1).delete_all
      variant.sequence_steps.where(position: 10, action_type: "betting").delete_all
    end
  end

  def down
    Variant.where(name: NAMES).find_each do |variant|
      next if variant.sequence_steps.where(position: 9).exists?

      variant.sequence_steps.create!(position: 9, action_type: "deal", card_scope: "individual", cards_down: 1)
      variant.sequence_steps.create!(position: 10, action_type: "betting")
    end
  end
end
