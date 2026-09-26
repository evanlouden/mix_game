class RemoveSoheSpecialSequenceSteps < ActiveRecord::Migration[8.1]
  SPECIAL_POSITIONS = [2, 3, 6].freeze

  def up
    Variant.where(name: "SOHE").find_each do |variant|
      next unless variant.sequence_steps.where(action_type: "special").exists?

      variant.sequence_steps.where(action_type: "special").delete_all
      renumber(variant) { |position| position - SPECIAL_POSITIONS.count { |special_position| special_position < position } }
    end
  end

  def down
    Variant.where(name: "SOHE").find_each do |variant|
      renumber(variant) { |position| position > 1 ? position + 3 : position }
      [2, 3, 6].each { |position| variant.sequence_steps.create!(position: position, action_type: "special") }
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
