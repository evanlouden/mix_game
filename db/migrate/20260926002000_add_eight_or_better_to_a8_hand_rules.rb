class AddEightOrBetterToA8HandRules < ActiveRecord::Migration[8.1]
  def up
    HandRule.where(rule: "ace_to_five_low")
            .where("notes ILIKE '%A–8%' OR notes ILIKE '%A-8%'")
            .update_all(qualifier: "8 or better")
  end

  def down
    HandRule.where(rule: "ace_to_five_low", qualifier: "8 or better").update_all(qualifier: nil)
  end
end
