class SwapVeryCrazyPineappleSteps < ActiveRecord::Migration[8.1]
  VARIANT_NAMES = ["Very Crazy Pineapple", "Very Crazy Pineapple 8"].freeze

  def up
    Variant.where(name: VARIANT_NAMES).find_each do |variant|
      step_seven = variant.sequence_steps.find_by(position: 7)
      step_eight = variant.sequence_steps.find_by(position: 8)
      next unless step_seven && step_eight

      step_seven.update_columns(position: 0)
      step_eight.update_columns(position: 7)
      step_seven.update_columns(position: 8)
    end
  end

  def down
    Variant.where(name: VARIANT_NAMES).find_each do |variant|
      step_seven = variant.sequence_steps.find_by(position: 7)
      step_eight = variant.sequence_steps.find_by(position: 8)
      next unless step_seven && step_eight

      step_seven.update_columns(position: 0)
      step_eight.update_columns(position: 7)
      step_seven.update_columns(position: 8)
    end
  end
end
