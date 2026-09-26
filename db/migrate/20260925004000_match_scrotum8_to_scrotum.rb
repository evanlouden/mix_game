class MatchScrotum8ToScrotum < ActiveRecord::Migration[8.1]
  STEP_COLUMNS = %w[position action_type card_scope number_of_boards cards_down cards_up min_cards max_cards].freeze
  CORRECT_STEPS = [
    { position: 1, action_type: "deal", card_scope: "individual", cards_down: 5 },
    { position: 2, action_type: "discard", min_cards: 0, max_cards: 5 },
    { position: 5, action_type: "betting" },
    { position: 6, action_type: "deal", card_scope: "community", cards_up: 3 },
    { position: 10, action_type: "betting" },
    { position: 11, action_type: "deal", card_scope: "community", cards_up: 1 },
    { position: 12, action_type: "betting" },
    { position: 13, action_type: "deal", card_scope: "community", cards_up: 1 },
    { position: 14, action_type: "betting" }
  ].freeze

  def up
    scrotum = Variant.find_by(name: "Scrotum")
    scrotum_eight = Variant.find_by(name: "Scrotum 8")
    return unless scrotum && scrotum_eight

    replace_sequence(scrotum, CORRECT_STEPS)
    replace_sequence(scrotum_eight, CORRECT_STEPS)
  end

  def down
    # The prior migration established the opposite sequence; leaving both variants
    # on the corrected sequence is safer than restoring an obsolete copy.
  end

  private

  def replace_sequence(variant, steps)
    variant.sequence_steps.delete_all
    steps.each { |attributes| variant.sequence_steps.create!(attributes) }
  end
end
