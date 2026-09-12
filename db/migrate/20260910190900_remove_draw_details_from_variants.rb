class RemoveDrawDetailsFromVariants < ActiveRecord::Migration[8.1]
  def change
    remove_column :variants, :draw_details, :text if column_exists?(:variants, :draw_details)
  end
end
