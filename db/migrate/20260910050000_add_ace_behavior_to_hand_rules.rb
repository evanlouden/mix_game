class AddAceBehaviorToHandRules < ActiveRecord::Migration[8.1]
  def up
    add_column :hand_rules, :ace_behavior, :string
    add_index :hand_rules, :ace_behavior
    execute "UPDATE hand_rules SET ace_behavior = 'either' WHERE ace_behavior IS NULL"
  end

  def down
    remove_index :hand_rules, :ace_behavior
    remove_column :hand_rules, :ace_behavior
  end
end
