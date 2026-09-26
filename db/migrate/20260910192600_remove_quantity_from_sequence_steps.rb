class RemoveQuantityFromSequenceSteps < ActiveRecord::Migration[8.1]
  def change
    remove_column :sequence_steps, :quantity, :integer
  end
end
