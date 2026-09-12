class Variant < ApplicationRecord
  has_many :sequence_steps, -> { order(:position) }, dependent: :destroy, inverse_of: :variant
  has_many :hand_rules, -> { order(:pot_number, :id) }, dependent: :destroy, inverse_of: :variant
  accepts_nested_attributes_for :hand_rules
  FIELDS = {
    name: "Variant", betting_format: "Betting Format", family: "Family", max_players: "Max Players",
    forced_bet: "Forced Bet", bring_in: "Bring-In",
    betting_structure: "Betting Limit / Category",
    starting_cards_down: "Starting Cards Down", starting_cards_up: "Starting Cards Up",
    split_pot: "Split Pot", qualifier: "Low / Other Qualifier",
    high_hand: "High-Hand Mechanics", low_hand: "Low-Hand Mechanics",
    final_hand: "Final Hand / Construction", wild_cards: "Wild Cards", deck_modification: "Deck Modification",
    pot_1_qualifier: "Pot 1 Qualifier", pot_2_qualifier: "Pot 2 Qualifier",
    action_order: "Action Order", special_mechanics: "Special Mechanics", best_hand: "Best Hand",
    source_pages: "Source Pages", source_notes: "Source Notes", pot_1_hand_rule: "Pot 1 Hand Rule", pot_2_hand_rule: "Pot 2 Hand Rule"
  }.freeze
  GROUPS = {
    "The basics" => %i[name betting_format family max_players],
    "Betting & action" => %i[forced_bet bring_in betting_structure action_order],
    "Cards & draws" => %i[starting_cards_down starting_cards_up],
    "Hands & winning" => %i[split_pot qualifier pot_1_qualifier pot_2_qualifier high_hand low_hand final_hand best_hand pot_1_hand_rule pot_2_hand_rule],
    "Special rules" => %i[wild_cards deck_modification special_mechanics],
    "Source & notes" => %i[source_pages source_notes]
  }.freeze
  LONG_FIELDS = %i[qualifier high_hand low_hand final_hand wild_cards deck_modification action_order special_mechanics source_notes].freeze
  FAMILIES = [ "Draw", "Hold'em", "Omaha", "Stud" ].freeze
  GAME_TYPES = [ "Big-Bet", "Fixed-Limit" ].freeze

  validates :name, :family, presence: true
  BETTING_FORMATS = %w[fixed_limt pot_limit no_limit].freeze
  BETTING_FORMAT_LABELS = { "fixed_limt" => "Fixed-Limit", "pot_limit" => "Pot-Limit", "no_limit" => "No-Limit" }.freeze
  validates :betting_format, inclusion: { in: BETTING_FORMATS }, allow_blank: true
  validates :max_players, numericality: { only_integer: true, greater_than: 0 }, allow_blank: true
  validates :source_id, uniqueness: true, allow_nil: true

  def self.filtered(filters)
    scope = all
    if filters[:q].present?
      term = "%#{sanitize_sql_like(filters[:q].strip)}%"
      scope = scope.where("name ILIKE :q OR special_mechanics ILIKE :q OR final_hand ILIKE :q", q: term)
    end
    %i[family betting_structure split_pot].each do |field|
      scope = scope.where(field => filters[field]) if filters[field].present?
    end
    scope.order(:name, :betting_structure, :id)
  end
end
