class SequenceStep < ApplicationRecord
  belongs_to :variant, inverse_of: :sequence_steps

  TYPES = %w[deal betting draw discard separate special showdown].freeze

  validates :position, numericality: { only_integer: true, greater_than: 0 }
  validates :action_type, presence: true, inclusion: { in: TYPES }
  validates :label, presence: true
  validates :quantity, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true

  def display_label
    return "#{quantity} #{quantity_unit.presence || 'cards'}" if quantity.present? && label.blank?

    label
  end
end
