module HandRulesHelper
  def variant_hand_rule_label(variant, pot_number)
    rule = variant.public_send("pot_#{pot_number}_hand_rule")
    return if rule.blank?

    Variant::HAND_RULE_LABELS.fetch(rule.to_s, rule.to_s.humanize)
  end

  def variant_hand_qualifier_label(variant, pot_number)
    qualifier = variant.public_send("pot_#{pot_number}_qualifier")
    return if qualifier.blank?

    Variant::POT_QUALIFIERS.fetch(qualifier.to_s, qualifier)
  end
end
