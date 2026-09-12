# frozen_string_literal: true

class CardComponent < ApplicationComponent
  def initialize(header: nil)
    @header = header
  end

  private

  attr_reader :header
end
