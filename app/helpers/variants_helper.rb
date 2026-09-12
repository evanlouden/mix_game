module VariantsHelper
  def sequence_label_markup(label)
    return content_tag(:span, "💰", class: "bet-marker", aria: { label: "betting round" }) if label.to_s == "BET"

    label = label.to_s.gsub(/\bDRAW\s+(\d+)\b/i, 'DRAW #\1')

    if (discard = label.match(/\ADISCARD\s+(\d+)\s+CARD(?:S)?\z/i))
      count = Integer(discard[1])
      return render SequenceCardComponent.new(state: "discard", count: count)
    end

    if (draw = label.match(/\ADRAW\s+#?(\d+)(?:\s+(\d+)-(\d+))?\z/i))
      range = draw[2] && draw[3] ? "#{draw[2]}-#{draw[3]}" : draw[1]
      return render SequenceCardComponent.new(state: "draw", count: range)
    end

    if (deal = label.to_s.match(/\A(\d+) DOWN \+ (\d+) UP\z/))
      down_count = Integer(deal[1])
      down = down_count.times.map.with_index { |_, index| content_tag(:span, index == down_count - 1 ? down_count : "", class: "sequence-playing-card face-down", aria: { label: "face-down card #{index + 1}" }) }
      up = Integer(deal[2]).times.map { content_tag(:span, "1", class: "sequence-playing-card", aria: { label: "face-up player card" }) }
      return safe_join(down + up, " ")
    end

    if (up_count = label.to_s.match(/\A(\d+) UP\z/))
      return safe_join(Integer(up_count[1]).times.map { content_tag(:span, "1", class: "sequence-playing-card", aria: { label: "face-up player card" }) }, " ")
    end

    if (down_count = label.to_s.match(/\A(\d+) DOWN\z/))
      count = Integer(down_count[1])
      return safe_join(count.times.map.with_index { |_, index| content_tag(:span, index == count - 1 ? count : "", class: "sequence-playing-card face-down", aria: { label: "face-down card #{index + 1}" }) }, " ")
    end

    tokens = label.to_s.split(" ")
    safe_join(tokens.map do |token|
      if token == "C"
        content_tag(:span, "C", class: "sequence-playing-card", aria: { label: "face-up card" })
      else
        token
      end
    end, " ").html_safe
  end
end
