class StandardFlopSequence
  STEP_ATTRIBUTES = %i[action_type card_scope number_of_boards cards_down cards_up min_cards max_cards].freeze

  def self.call(variant, hole_cards: 2)
    new(variant, hole_cards: hole_cards).call
  end

  def initialize(variant, hole_cards: 2)
    @variant = variant
    @hole_cards = Integer(hole_cards)
    raise ArgumentError, "hole_cards must be greater than zero" unless @hole_cards.positive?
  end

  def call
    @variant.with_lock do
      existing_steps = @variant.sequence_steps.order(:position).to_a
      return existing_steps if matches_standard_sequence?(existing_steps)

      @variant.sequence_steps.delete_all
      steps.map.with_index do |attributes, index|
        @variant.sequence_steps.create!(attributes.merge(position: index + 1))
      end
    end
  end

  private

  def steps
    [
      { action_type: "deal", card_scope: "individual", cards_down: @hole_cards },
      { action_type: "betting" },
      { action_type: "deal", card_scope: "community", cards_up: 3 },
      { action_type: "betting" },
      { action_type: "deal", card_scope: "community", cards_up: 1 },
      { action_type: "betting" },
      { action_type: "deal", card_scope: "community", cards_up: 1 },
      { action_type: "betting" }
    ]
  end

  def matches_standard_sequence?(existing_steps)
    expected_steps = steps
    existing_steps.length == expected_steps.length && existing_steps.zip(expected_steps).all? do |step, expected|
      STEP_ATTRIBUTES.all? { |attribute| step.public_send(attribute) == expected[attribute] }
    end
  end
end
