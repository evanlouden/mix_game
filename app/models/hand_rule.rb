class HandRule < ApplicationRecord
  ACE_BEHAVIORS = %w[high low either].freeze
  RANKING_RULES = %w[standard_high ace_to_five_low deuce_to_seven_low badugi badeucey pip_count_high pip_count_low].freeze
  RANKING_LABELS = { "standard_high" => "Standard", "ace_to_five_low" => "A-5", "deuce_to_seven_low" => "2-7", "badugi" => "Badugi", "badeucey" => "Badeucey", "pip_count_high" => "Pip Count High", "pip_count_low" => "Pip Count Low" }.freeze
  belongs_to :variant, inverse_of: :hand_rules
  before_validation :normalize_standard_high_ace_behavior

  validates :pot_number, numericality: { only_integer: true, greater_than: 0 }
  validates :hand_size, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :rule, presence: true, inclusion: { in: RANKING_RULES }
  validates :ace_behavior, inclusion: { in: ACE_BEHAVIORS }, allow_nil: true

  def construction_label
    return "Best #{hand_size || 5} cards" if hole_cards_required.blank? && community_cards_required.blank? && rule == "standard_high"
    return notes.presence || "Best #{hand_size || 5}-card hand" unless hole_cards_required.present? || community_cards_required.present?

    parts = []
    parts << "best #{hole_cards_required} hole" if hole_cards_required.present?
    parts << "best #{community_cards_required} community" if community_cards_required.present?
    parts.empty? ? "Best #{hand_size || 5} cards" : parts.join(" + ").sub(/\Abest /, "Best ")
  end

  private

  def normalize_standard_high_ace_behavior
    self.ace_behavior = "either" if rule == "standard_high"
  end
end
