class Variant < ApplicationRecord
  has_many :sequence_steps, -> { order(:position) }, dependent: :destroy, inverse_of: :variant
  FIELDS = {
    name: "Name", no_limit: "No Limit", pot_limit: "Pot Limit", fixed_limit: "Limit", bomb_pot: "Bomb Pot", family: "Family", max_players: "Max Players",
    forced_bet: "Forced Bet", bring_in: "Bring-In",
    pot_1_qualifier: "Pot 1 Qualifier", pot_2_qualifier: "Pot 2 Qualifier",
    special_mechanics: "Special Mechanics", pot_1_hand_rule: "Pot 1 Hand Rule", pot_2_hand_rule: "Pot 2 Hand Rule"
  }.freeze
  GROUPS = {
    "The basics" => %i[family max_players],
    "Betting & action" => %i[forced_bet bring_in]
  }.freeze
  LONG_FIELDS = %i[special_mechanics].freeze
  FAMILIES = [ "Draw", "Hold'em", "Omaha", "Stud" ].freeze
  GAME_TYPES = [ "Big-Bet", "Fixed-Limit" ].freeze
  HAND_RULES = %w[high_standard high_omaha king_to_nine_high ace_to_five_low deuce_to_seven_low badugi badugi_high highest_spade_in_hole lowest_spade_in_hole pip_count_high pip_count_low].freeze
  HAND_RULE_LABELS = { "high_standard" => "High (5 best)", "high_omaha" => "High (Omaha)", "king_to_nine_high" => "High (K-9)", "ace_to_five_low" => "Low A-5", "deuce_to_seven_low" => "2-7", "badugi" => "Badugi", "badugi_high" => "Badugi (A high)", "highest_spade_in_hole" => "Highest Spade in the Hole", "lowest_spade_in_hole" => "Lowest Spade in the Hole", "pip_count_high" => "Pip Count High", "pip_count_low" => "Pip Count Low" }.freeze
  FORCED_BETS = ["Antes", "Blinds"].freeze
  BRING_INS = { "high" => "High", "low" => "Low", "none" => "None" }.freeze
  POT_QUALIFIERS = {
    "seven" => "7 or better",
    "eight" => "8 or better",
    "jacks" => "JJ+",
    "nines" => "99+",
    "hole_cards" => "All hole cards",
    "flush_or_better" => "Flush or better",
    "trips_or_better" => "Trips or better",
    "top_board" => "Top board",
    "bottom_board" => "Bottom board",
    "face_card" => "Face Card"
  }.freeze

  validates :name, :family, presence: true
  BETTING_OPTION_LABELS = { no_limit: "No Limit", pot_limit: "Pot Limit", fixed_limit: "Limit" }.freeze
  validates :max_players, numericality: { only_integer: true, greater_than: 0 }, allow_blank: true

  def self.filtered(filters)
    scope = all
    if filters[:q].present?
      term = "%#{sanitize_sql_like(filters[:q].strip)}%"
      scope = scope.where("LOWER(name) LIKE LOWER(:q) OR LOWER(special_mechanics) LIKE LOWER(:q)", q: term)
    end
    if filters[:family].present?
      scope = scope.where(family: filters[:family])
    end
    if filters[:split_pot].present?
      scope = if filters[:split_pot] == "Yes"
        scope.where.not(pot_2_hand_rule: [nil, ""])
      else
        scope.where(pot_2_hand_rule: [nil, ""])
      end
    end
    scope.order(:name, :id)
  end

  def betting_format_labels
    BETTING_OPTION_LABELS.filter_map { |field, label| label if public_send(field) }
  end

  def betting_format_display
    betting_format_labels.join(" / ").presence || "Betting format unspecified"
  end
end
