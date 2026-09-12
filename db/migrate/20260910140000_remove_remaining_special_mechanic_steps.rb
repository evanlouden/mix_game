class RemoveRemainingSpecialMechanicSteps < ActiveRecord::Migration[8.1]
  def up
    SequenceStep.where(label: "Special mechanic").delete_all
  end

  def down
    # These generic imported rows are intentionally not restored.
  end
end
