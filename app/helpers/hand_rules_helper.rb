module HandRulesHelper
  def hand_rule_display(rule)
    label = hand_rule_label(rule)
    nuts = hand_rule_nuts(rule)
    nuts.present? ? "#{label} · Nuts: #{nuts}" : label
  end

  def hand_rule_label(rule)
    label = hand_rule_base_label(rule)
    marker = ace_behavior_marker(rule)
    label = "#{label} #{marker}" if marker.present?
    label
  end

  def hand_rule_base_label(rule)
    label = rule.construction_label
    if rule.rule == "high_omaha"
      label = "High (Omaha)"
    elsif rule.rule == "standard_high"
      label = "High (#{rule.hand_size || 5} best)"
    elsif rule.rule == "pip_count_high"
      label = "Pip Count High"
    elsif rule.rule == "pip_count_low"
      label = "Pip Count Low"
    elsif rule.direction == "high"
      label = "High (#{rule.hand_size || 5} best)"
    elsif rule.rule.in?(%w[ace_to_five_low deuce_to_seven_low badugi badeucey]) || rule.direction == "low"
      label = low_rule_name(rule)
    end
    label = "#{label} (#{rule.qualifier})" if rule.qualifier.present?
    label
  end

  def hand_rule_nuts(rule)
    low_nuts_example(rule)
  end

  def low_rule_name(rule)
    notes = rule.notes.to_s
    return "Badeucey" if rule.rule == "badeucey"
    return "Badugi" if rule.rule == "badugi" || notes.match?(/Badugi/i)
    return "2-7" if rule.rule == "deuce_to_seven_low" || notes.match?(/2[–-]7/i)
    return "Low A-8" if rule.rule == "ace_to_five_low" || notes.match?(/A[–-]5/i)
    return "Low A-8" if notes.match?(/A[–-]8/i)
    return "Low A-8" if notes.match?(/Razz/i)

    "Low A-8"
  end

  def low_nuts_example(rule)
    return if rule.rule.in?(%w[standard_high high_omaha])
    return if rule.direction != "low" && !rule.rule.in?(%w[ace_to_five_low deuce_to_seven_low badugi badeucey])

    notes = rule.notes.to_s
    return "75432" if notes.match?(/2[–-]7/i)
    return "5432 rainbow" if rule.rule == "badeucey" || notes.match?(/Ace is high/i)
    return "432A rainbow" if rule.rule == "badugi" || notes.match?(/Badugi/i)
    return "75432" if rule.rule == "deuce_to_seven_low" || notes.match?(/2[–-]7|2–7/i)
    return "5432A" if rule.rule == "ace_to_five_low" || notes.match?(/Razz|A[–-]5|A[–-]8|Ace is low|unique ranks/i)

    "A2345"
  end

  def ace_behavior_marker(rule)
    return nil if rule.rule.in?(%w[standard_high high_omaha pip_count_high pip_count_low])
    behavior = rule.ace_behavior.presence || {
      "ace_to_five_low" => "low",
      "deuce_to_seven_low" => "high",
      "badugi" => "low",
      "badeucey" => "high"
    }.fetch(rule.rule, nil)
    { "high" => "A⬆", "low" => "A⬇", "either" => "A↕" }.fetch(behavior, nil)
  end
end
