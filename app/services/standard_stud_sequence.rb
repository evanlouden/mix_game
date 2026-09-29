class StandardStudSequence
  STEP_ATTRIBUTES = %i[action_type card_scope number_of_boards cards_down cards_up min_cards max_cards].freeze

  STEPS = [
    { action_type: "deal", card_scope: "individual", cards_down: 2, cards_up: 1 },
    { action_type: "betting" },
    { action_type: "deal", card_scope: "individual", cards_up: 1 },
    { action_type: "betting" },
    { action_type: "deal", card_scope: "individual", cards_up: 1 },
    { action_type: "betting" },
    { action_type: "deal", card_scope: "individual", cards_up: 1 },
    { action_type: "betting" },
    { action_type: "deal", card_scope: "individual", cards_down: 1 },
    { action_type: "betting" }
  ].freeze

  def self.call(variant)
    new(variant).call
  end

  def initialize(variant)
    @variant = variant
  end

  def call
    @variant.with_lock do
      existing_steps = @variant.sequence_steps.order(:position).to_a
      return existing_steps if matches_standard_sequence?(existing_steps)

      @variant.sequence_steps.delete_all
      STEPS.each_with_index.map do |attributes, index|
        @variant.sequence_steps.create!(attributes.merge(position: index + 1))
      end
    end
  end

  private

  def matches_standard_sequence?(steps)
    steps.length == STEPS.length && steps.zip(STEPS).all? do |step, expected|
      STEP_ATTRIBUTES.all? { |attribute| step.public_send(attribute) == expected[attribute] }
    end
  end
end
