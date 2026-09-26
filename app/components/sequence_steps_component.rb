# frozen_string_literal: true

class SequenceStepsComponent < ApplicationComponent
  def initialize(sequence: [])
    @sequence = sequence || []
  end

  private

  attr_reader :sequence

  def labels
    sequence.map.with_index do |event, index|
      type = event["event_type"].to_s.downcase
      community_cards = event["community_card_count"].to_i
      hole_cards = event["hole_card_count"].to_i
      up_cards = event["up_card_count"].to_i

      if %w[community deal].include?(type) && community_cards.positive?
        (["C"] * community_cards).join(" ")
      elsif type == "deal" && hole_cards.positive?
        up_cards.positive? ? "#{hole_cards} DOWN + #{up_cards} UP" : "#{hole_cards} DOWN"
      elsif type == "deal" && up_cards.positive?
        "#{up_cards} UP"
      elsif type == "betting"
        "BET"
      elsif type == "draw"
        draw_number = event["event_name"].to_s[/\d+/] || sequence.first(index + 1).count { |item| item["event_type"].to_s.downcase == "draw" }
        draw_max = event["max_cards"].presence || sequence.first["hole_card_count"].presence || 5
        draw_min = event.key?("min_cards") ? event["min_cards"].to_i : 0
        "DRAW #{draw_number} #{card_range(draw_min, draw_max)}"
      elsif type == "discard" || event["event_name"].to_s.casecmp("discard").zero?
        discard_count = event["discard_card_count"].to_i.positive? ? event["discard_card_count"].to_i : event["event_name"].to_s[/\d+/] || 1
        discard_max = event["max_cards"].presence || discard_count
        discard_min = event.key?("min_cards") ? event["min_cards"].to_i : discard_count
        "DISCARD #{card_range(discard_min, discard_max)} CARD"
      elsif %w[expose reveal].include?(type)
        "EXPOSE #{event["cards_up"].presence || event["event_name"].to_s[/\d+/] || 2} CARDS"
      elsif type == "special"
        (event["event_name"].presence || "SPECIAL").upcase
      else
        event["event_name"].presence || type.humanize
      end
    end
  end

  def label_markup(label)
    helpers.sequence_label_markup(label)
  end

  def card_range(min_cards, max_cards)
    min_cards.to_i == max_cards.to_i ? max_cards.to_i : "#{min_cards}-#{max_cards}"
  end
end
