class AddPotHandRuleSummaries < ActiveRecord::Migration[8.1]
  def up
    add_column :variants, :pot_1_hand_rule, :text
    add_column :variants, :pot_2_hand_rule, :text
    Variant.reset_column_information
    Variant.find_each do |variant|
      rules = variant.hand_rules.index_by(&:pot_number)
      variant.update_columns(
        pot_1_hand_rule: rules[1]&.notes.presence || rules[1]&.construction_label,
        pot_2_hand_rule: rules[2]&.notes.presence || rules[2]&.construction_label
      )
    end
  end

  def down
    remove_column :variants, :pot_1_hand_rule
    remove_column :variants, :pot_2_hand_rule
  end
end
