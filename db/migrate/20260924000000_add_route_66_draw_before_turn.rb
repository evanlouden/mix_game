class AddRoute66DrawBeforeTurn < ActiveRecord::Migration[8.1]
  def up
    Variant.where(name: "Route 66").find_each do |variant|
      next if variant.sequence_steps.where(position: 5, action_type: "draw").exists?

      variant.sequence_steps.where("position >= 5").update_all("position = position + 1000")
      variant.sequence_steps.where("position >= 1005").update_all("position = position - 999")
      variant.sequence_steps.create!(position: 5, action_type: "draw", max_cards: variant.starting_cards_down.presence || 6)
    end
  end

  def down
    Variant.where(name: "Route 66").find_each do |variant|
      draw_step = variant.sequence_steps.find_by(position: 5, action_type: "draw")
      next unless draw_step

      draw_step.destroy!
      variant.sequence_steps.where("position > 5").update_all("position = position - 1")
    end
  end
end
