class MaterializeHandRulesOnVariants < ActiveRecord::Migration[8.1]
  def up
    execute <<~SQL
      UPDATE variants
      SET pot_1_hand_rule = hand_rules.rule,
          pot_1_qualifier = NULLIF(hand_rules.qualifier, '')
      FROM hand_rules
      WHERE hand_rules.variant_id = variants.id
        AND hand_rules.pot_number = 1
    SQL
    execute <<~SQL
      UPDATE variants
      SET pot_2_hand_rule = hand_rules.rule,
          pot_2_qualifier = NULLIF(hand_rules.qualifier, '')
      FROM hand_rules
      WHERE hand_rules.variant_id = variants.id
        AND hand_rules.pot_number = 2
    SQL

    drop_table :hand_rules
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "Hand rules were materialized on variants and cannot be restored safely"
  end
end
