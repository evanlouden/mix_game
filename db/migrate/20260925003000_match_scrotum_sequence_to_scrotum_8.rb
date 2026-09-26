class MatchScrotumSequenceToScrotum8 < ActiveRecord::Migration[8.1]
  STEP_COLUMNS = %w[position action_type card_scope number_of_boards cards_down cards_up min_cards max_cards].freeze

  def up
    source = Variant.find_by(name: "Scrotum 8")
    target = Variant.find_by(name: "Scrotum")
    return unless source && target

    copy_steps(source, target)
  end

  def down
    target = Variant.find_by(name: "Scrotum")
    return unless target

    target.sequence_steps.delete_all
    [
      { position: 1, action_type: "deal", card_scope: "individual", cards_down: 5 },
      { position: 2, action_type: "discard", min_cards: 0, max_cards: 5 },
      { position: 5, action_type: "betting" },
      { position: 6, action_type: "deal", card_scope: "community", cards_up: 3 },
      { position: 10, action_type: "betting" },
      { position: 11, action_type: "deal", card_scope: "community", cards_up: 1 },
      { position: 12, action_type: "betting" },
      { position: 13, action_type: "deal", card_scope: "community", cards_up: 1 },
      { position: 14, action_type: "betting" }
    ].each { |attributes| target.sequence_steps.create!(attributes) }
  end

  private

  def copy_steps(source, target)
    steps = source.sequence_steps.order(:position).map { |step| step.attributes.slice(*STEP_COLUMNS) }
    target.sequence_steps.delete_all
    steps.each { |attributes| target.sequence_steps.create!(attributes) }
  end
end
