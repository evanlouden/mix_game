class NormalizeStandardHighAceBehavior < ActiveRecord::Migration[8.1]
  def up
    HandRule.where(rule: "standard_high").update_all(ace_behavior: "either")
  end

  def down
    # Standard-high Ace behavior is intentionally neutral.
  end
end
