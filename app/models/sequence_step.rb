class SequenceStep < ApplicationRecord
  belongs_to :variant, inverse_of: :sequence_steps

  TYPES = %w[deal up draw discard betting separate expose reveal showdown define_hands special].freeze
  CARD_SCOPES = %w[individual community].freeze

  validates :position, numericality: { only_integer: true, greater_than: 0 }
  validates :action_type, presence: true, inclusion: { in: TYPES }
  validates :min_cards, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
  validates :max_cards, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validate :min_cards_not_greater_than_max_cards
  validates :cards_down, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :cards_up, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :card_scope, inclusion: { in: CARD_SCOPES }, allow_blank: true

  private

  def min_cards_not_greater_than_max_cards
    return if min_cards.blank? || max_cards.blank? || min_cards <= max_cards

    errors.add(:min_cards, "must be less than or equal to maximum cards")
  end
end
