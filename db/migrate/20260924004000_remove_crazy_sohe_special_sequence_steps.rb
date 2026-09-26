class RemoveCrazySoheSpecialSequenceSteps < ActiveRecord::Migration[8.1]
  def up
    Variant.where(name: "Crazy SOHE").find_each do |variant|
      special_steps = variant.sequence_steps.where(action_type: "special")
      next unless special_steps.exists?

      special_positions = special_steps.pluck(:position)
      special_steps.delete_all
      renumber(variant) do |position|
        position - special_positions.count { |special_position| special_position < position }
      end
    end
  end

  def down
    Variant.where(name: "Crazy SOHE").find_each do |variant|
      next if variant.sequence_steps.where(action_type: "special").exists?

      renumber(variant) { |position| position > 3 ? position + 4 : position }
      [4, 5, 8, 9].each { |position| variant.sequence_steps.create!(position: position, action_type: "special") }
    end
  end

  private

  def renumber(variant)
    steps = variant.sequence_steps.to_a
    steps.each { |step| step.update_columns(position: step.position + 1000) }
    steps.each do |step|
      old_position = step.position - 1000
      step.update_columns(position: yield(old_position))
    end
  end
end
