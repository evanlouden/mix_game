class RemoveBettingRoundsFromVariants < ActiveRecord::Migration[8.1]
  def change
    remove_column :variants, :betting_rounds, :text if column_exists?(:variants, :betting_rounds)
  end
end
