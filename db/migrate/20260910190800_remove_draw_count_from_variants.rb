class RemoveDrawCountFromVariants < ActiveRecord::Migration[8.1]
  def change
    remove_column :variants, :draw_count, :text if column_exists?(:variants, :draw_count)
  end
end
