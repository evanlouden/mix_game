# frozen_string_literal: true

class PlayingCardComponent < ApplicationComponent
  STATES = %w[down community discard draw expose up].freeze

  def initialize(state:, value:, label: nil, overlap: false)
    raise ArgumentError, "Unknown card state" unless STATES.include?(state.to_s)

    @state = state.to_s
    @value = value
    @label = label || default_label
    @overlap = overlap
  end

  private

  attr_reader :state, :value, :label

  def classes
    ["playing-card-face", "sequence-playing-card", "playing-card--#{state}", (@overlap ? "playing-card--overlap" : nil), legacy_state_class].compact.join(" ")
  end

  def legacy_state_class
    {
      "down" => "face-down",
      "discard" => "discard-card",
      "up" => "individual-up-card"
    }.fetch(state, nil)
  end

  def default_label
    state == "discard" ? "discard #{value} cards" : "#{state} card"
  end
end
