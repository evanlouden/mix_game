class SequenceStepsComponentPreview < Lookbook::Preview
  # @param variant_id [Integer] "Variant ID to preview"
  def default(variant_id: 2)
    variant = Variant.find(variant_id)
    sequence = variant.sequence_steps.map do |step|
      {
        "event_type" => step.action_type,
        "event_name" => step.action_type.humanize,
        "hole_card_count" => step.card_scope == "individual" ? step.cards_down.to_s : "0",
        "up_card_count" => step.card_scope == "individual" ? step.cards_up.to_s : "0",
        "community_card_count" => step.card_scope == "community" ? step.cards_up.to_s : "0",
        "min_cards" => step.min_cards,
        "max_cards" => step.max_cards
      }
    end

    render SequenceStepsComponent.new(sequence: sequence)
  end
end
