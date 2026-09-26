class AddDrawBeforeTurnToOmahaWithDraw < ActiveRecord::Migration[8.1]
  def up
    Variant.where(name: [
      "2 or 5 Omaha with Draw",
      "2 or 5 Omaha 8 with Draw"
    ]).find_each do |variant|
      next if variant.sequence_steps.where(action_type: "draw").exists?

      variant.sequence_steps.where("position >= 5").update_all("position = position + 1000")
      variant.sequence_steps.where("position >= 1005").update_all("position = position - 999")
      variant.sequence_steps.create!(position: 5, action_type: "draw", max_cards: variant.starting_cards_down.presence || 5)
    end
  end

  def down
    Variant.where(name: [
      "2 or 5 Omaha with Draw",
      "2 or 5 Omaha 8 with Draw"
    ]).find_each do |variant|
      draw_step = variant.sequence_steps.find_by(position: 5, action_type: "draw")
      next unless draw_step

      draw_step.destroy!
      variant.sequence_steps.where("position > 5").update_all("position = position - 1")
    end
  end
end
