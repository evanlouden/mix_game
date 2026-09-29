class NormalizeOmahaHighHandRules < ActiveRecord::Migration[8.1]
  def up
    execute <<~SQL
      UPDATE variants
      SET pot_1_hand_rule = 'high_omaha'
      WHERE family = 'Omaha' AND pot_1_hand_rule = 'standard_high'
    SQL
    execute <<~SQL
      UPDATE variants
      SET pot_2_hand_rule = 'high_omaha'
      WHERE family = 'Omaha' AND pot_2_hand_rule = 'standard_high'
    SQL
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "Omaha high hand rules were normalized and cannot be restored safely"
  end
end
