class Variant < ApplicationRecord
  has_many :sequence_steps, -> { order(:position) }, dependent: :destroy, inverse_of: :variant
  FIELDS = {
    name: "Name", no_limit: "No Limit", pot_limit: "Pot Limit", fixed_limit: "Limit", bomb_pot: "Bomb Pot", family: "Family", modifiers: "Modifiers", max_players: "Max Players",
    forced_bet: "Forced Bet", bring_in: "Bring-In",
    pot_1_qualifier: "Pot 1 Qualifier", pot_2_qualifier: "Pot 2 Qualifier",
    special_mechanics: "Special Mechanics", pot_1_hand_rule: "Pot 1 Hand Rule", pot_2_hand_rule: "Pot 2 Hand Rule"
  }.freeze
  GROUPS = {
    "The basics" => %i[family modifiers max_players],
    "Betting & action" => %i[forced_bet bring_in]
  }.freeze
  LONG_FIELDS = %i[special_mechanics].freeze
  FAMILIES = [ "Draw", "Hold'em", "Omaha", "Stud" ].freeze
  GAME_TYPES = [ "Big-Bet", "Fixed-Limit" ].freeze
  MODIFIERS = {
    "double_board" => "Double Board",
    "derailment" => "Derailment"
  }.freeze
  BOARD_STYLE_COUNTS = { "double_board" => 2, "derailment" => 3 }.freeze
  MODIFIER_DESCRIPTIONS = {
    "double_board" => "Two boards are dealt. The pot is split among the two boards.",
    "derailment" => "Three boards are dealt. The board with the lowest-ranking river card is eliminated. If two boards tie for the lowest river card, both are eliminated. If all three river cards tie, all three boards remain in play. The pot is split among the surviving boards."
  }.freeze
  serialize :modifiers, coder: JSON
  scope :bomb_pot_eligible, -> { where(bomb_pot: true, pot_2_hand_rule: [nil, ""]) }
  HAND_RULES = {
    "high_standard" => "High (5 best)",
    "high_omaha" => "High (Omaha)",
    "king_to_nine_high" => "High (K-9)",
    "ace_to_five_low" => "Low A-5",
    "deuce_to_seven_low" => "2-7",
    "badugi" => "Badugi",
    "badugi_high" => "Badugi (A high)",
    "hi_dugi" => "Hi-dugi",
    "highest_spade_in_hole" => "Highest Spade in the Hole",
    "lowest_spade_in_hole" => "Lowest Spade in the Hole",
    "pip_count_high" => "Pip Count High",
    "pip_count_low" => "Pip Count Low"
  }.freeze
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
    "face_card" => "Face Card",
    "thirty_five_pip_count" => "35 Pip Count",
    "eight_pip_count" => "8 Pip Count"
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
    if filters[:betting_format].present?
      betting_field = { "pot_limit" => :pot_limit, "no_limit" => :no_limit, "fixed_limit" => :fixed_limit }[filters[:betting_format]]
      scope = scope.where(betting_field => true) if betting_field
    end
    if filters[:bomb_pot].present? && %w[Yes No].include?(filters[:bomb_pot])
      scope = scope.where(bomb_pot: filters[:bomb_pot] == "Yes")
    end
    scope = scope.where(max_players: filters[:players]) if filters[:players].present?
    scope.order(:name, :id)
  end

  def betting_format_labels
    BETTING_OPTION_LABELS.filter_map { |field, label| label if public_send(field) }
  end

  def derailment_eligible?
    bomb_pot? && pot_2_hand_rule.blank?
  end

  alias board_style_eligible? derailment_eligible?

  def betting_format_display
    betting_format_labels.join(" / ").presence || "Betting format unspecified"
  end
end
