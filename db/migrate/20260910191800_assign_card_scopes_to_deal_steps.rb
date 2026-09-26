class AssignCardScopesToDealSteps < ActiveRecord::Migration[8.1]
  def up
    Variant.find_each do |variant|
      normalize_existing_steps(variant)
      add_source_deal_steps(variant)
    end
  end

  def down
    # Card scopes are retained on rollback.
  end

  private

  def normalize_existing_steps(variant)
    variant.sequence_steps.find_each do |step|
      text = ""
      if step.action_type == "community" || step.quantity_unit == "community cards" || text.match?(/\A(?:C\s*)+\z/)
        step.update_columns(card_scope: "community", action_type: "deal")
      elsif step.action_type == "deal" || step.quantity_unit == "cards" || step.cards_down.present? || step.cards_up.present? || text.match?(/\b(?:DOWN|UP)\b/)
        down = text[/([0-9]+)\s+DOWN/, 1]&.to_i
        up = text[/([0-9]+)\s+UP/, 1]&.to_i
        step.update_columns(card_scope: "individual", action_type: "deal", cards_down: down.presence || step.cards_down, cards_up: up.presence || step.cards_up)
      end
    end
  end

  def add_source_deal_steps(variant)
    variant.source_detail.to_h.fetch("sequence", []).each_with_index do |event, index|
      type = event["event_type"].to_s.downcase
      community = event["community_card_count"].to_i
      hole = event["hole_card_count"].to_i
      up = event["up_card_count"].to_i
      next unless %w[deal community up].include?(type) || community.positive? || hole.positive? || up.positive?

      step = variant.sequence_steps.find_by(position: index + 1)
      if community.positive?
        attrs = { action_type: "deal", card_scope: "community", number_of_cards: community, quantity_unit: "community cards" }
      else
        attrs = { action_type: "deal", card_scope: "individual", cards_down: hole.positive? ? hole : nil, cards_up: up.positive? ? up : nil, number_of_cards: [hole, up].sum.positive? ? [hole, up].sum : nil, quantity_unit: hole.positive? ? "cards" : nil }
      end
      if step
        step.update_columns(attrs)
      else
        variant.sequence_steps.create!(attrs.merge(position: index + 1))
      end
    end
  end
end
