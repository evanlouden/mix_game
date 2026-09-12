class RemoveGameTypeFromVariants < ActiveRecord::Migration[8.1]
  def change
    remove_column :variants, :game_type, :text if column_exists?(:variants, :game_type)
  end
end
