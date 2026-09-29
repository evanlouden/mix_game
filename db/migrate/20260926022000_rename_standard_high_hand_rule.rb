class RenameStandardHighHandRule < ActiveRecord::Migration[8.1]
  def up
    execute <<~SQL
      UPDATE variants
      SET pot_1_hand_rule = 'high_standard'
      WHERE pot_1_hand_rule = 'standard_high'
    SQL
    execute <<~SQL
      UPDATE variants
      SET pot_2_hand_rule = 'high_standard'
      WHERE pot_2_hand_rule = 'standard_high'
    SQL
  end

  def down
    execute <<~SQL
      UPDATE variants
      SET pot_1_hand_rule = 'standard_high'
      WHERE pot_1_hand_rule = 'high_standard'
    SQL
    execute <<~SQL
      UPDATE variants
      SET pot_2_hand_rule = 'standard_high'
      WHERE pot_2_hand_rule = 'high_standard'
    SQL
  end
end
