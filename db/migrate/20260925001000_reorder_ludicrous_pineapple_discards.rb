class ReorderLudicrousPineappleDiscards < ActiveRecord::Migration[8.1]
  VARIANT_NAMES = ["Ludicrous Pineapple", "Ludicrous Pineapple 8"].freeze

  def up
    reorder_steps([6, 7, 5, 9, 10, 8])
  end

  def down
    reorder_steps([7, 5, 6, 10, 8, 9])
  end

  private

  def reorder_steps(source_positions)
    Variant.where(name: VARIANT_NAMES).find_each do |variant|
      steps = source_positions.map { |position| variant.sequence_steps.find_by(position: position) }
      next if steps.any?(&:nil?)

      steps.each_with_index { |step, index| step.update_columns(position: -(index + 1)) }
      steps.each_with_index { |step, index| step.update_columns(position: index + 5) }
    end
  end
end
