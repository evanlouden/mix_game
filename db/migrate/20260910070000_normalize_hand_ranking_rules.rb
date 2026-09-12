class NormalizeHandRankingRules < ActiveRecord::Migration[8.1]
  def up
    change_column_default :hand_rules, :rule, from: "best", to: "standard_high"
    HandRule.reset_column_information

    HandRule.includes(:variant).find_each do |hand_rule|
      text = [hand_rule.notes, hand_rule.variant.name].compact.join(" ")
      normalized = if hand_rule.notes.to_s.match?(/2[–-]7|Deuce\s+to\s+Seven/i)
        "deuce_to_seven_low"
      elsif text.match?(/Badeucey/i) && (hand_rule.direction == "high" || hand_rule.notes.to_s.match?(/Badugi/i))
        "badeucey"
      elsif text.match?(/Badugi/i)
        "badugi"
      elsif text.match?(/Razz|A[–-]5|Ace is low|lowball|Lowest/i) && hand_rule.direction == "low"
        "ace_to_five_low"
      else
        "standard_high"
      end

      attributes = { rule: normalized }
      attributes[:ace_behavior] = {
        "ace_to_five_low" => "low",
        "deuce_to_seven_low" => "high",
        "badugi" => "low",
        "badeucey" => "high"
      }[normalized]
      hand_rule.update_columns(attributes)
    end
  end

  def down
    change_column_default :hand_rules, :rule, from: "standard_high", to: "best"
    HandRule.where(rule: "standard_high").update_all(rule: "best")
    HandRule.where(rule: "ace_to_five_low").update_all(rule: "lowball")
    HandRule.where(rule: "deuce_to_seven_low").update_all(rule: "lowball")
    HandRule.where(rule: "badeucey").update_all(rule: "lowball")
  end
end
