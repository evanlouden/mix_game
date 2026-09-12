class RemoveErroneousRaiseToOpenSequenceSteps < ActiveRecord::Migration[8.1]
  def up
    SequenceStep.where(label: "Special mechanic").delete_all
  end

  def down
    # These imported sequence actions were erroneous and are intentionally not restored.
  end
end
