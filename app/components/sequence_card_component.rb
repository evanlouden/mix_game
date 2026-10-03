# frozen_string_literal: true

class SequenceCardComponent < ApplicationComponent
  STATES = %w[down community discard draw expose up].freeze

  def initialize(state:, count: 1)
    raise ArgumentError, "Unknown card state" unless STATES.include?(state.to_s)

    @state = state.to_s
    @count = count
  end

  private

  attr_reader :state, :count

  def card_values
    return [card_value] unless state == "down" && count.to_i > 1

    Array.new(count.to_i) { |index| index == count.to_i - 1 ? count : "" }
  end

  def card_value
    return count if %w[down discard].include?(state)
    return "C" if state == "community"
    return "I" if state == "up"

    count
  end

  def label
    state == "discard" ? "discard #{count} cards" : "#{state} card"
  end
end
