class RemoveSplitPotFromVariants < ActiveRecord::Migration[8.1]
  def change
    remove_column :variants, :split_pot, :text
  end
end
