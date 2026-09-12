# frozen_string_literal: true

class SequenceCardComponent < ApplicationComponent
  STATES = %w[down community discard draw].freeze

  def initialize(state:, count: 1)
    raise ArgumentError, "Unknown card state" unless STATES.include?(state.to_s)

    @state = state.to_s
    @count = count
  end

  private

  attr_reader :state, :count

  def card_class
    classes = ["sequence-playing-card"]
    classes << "face-down" if state == "down"
    classes << "discard-card" if state == "discard"
    classes.join(" ")
  end

  def card_value
    return count if %w[down discard].include?(state)
    return "C" if state == "community"

    count
  end

  def label
    state == "discard" ? "discard #{count} cards" : "#{state} card"
  end
end
