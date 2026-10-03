# frozen_string_literal: true

class PokerChipComponent < ApplicationComponent
  def initialize(count: 1)
    @count = 1
  end

  private

  attr_reader :count
end
